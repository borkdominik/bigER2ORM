import { postConstruct, inject, injectable } from 'inversify';
import { VscodeDiagramWidget } from 'sprotty-vscode-webview';
import { SprottyDiagramIdentifier } from 'sprotty-vscode-protocol';
import { DiagramServerProxy, IActionDispatcher, ILogger, ModelSource, TYPES } from 'sprotty';
import { CollapseExpandAllAction, FitToScreenAction } from 'sprotty-protocol';

@injectable()
export class OrmToolbarDiagramWidget extends VscodeDiagramWidget {

    @inject(TYPES.IActionDispatcher) actionDispatcher: IActionDispatcher;
    @inject(SprottyDiagramIdentifier) diagramIdentifier: SprottyDiagramIdentifier;
    @inject(TYPES.ILogger) protected logger: ILogger;
    @inject(TYPES.ModelSource) modelSource: ModelSource;

    constructor() {
        super();
    }

    @postConstruct()
    override initialize(): void {
        super.initialize();
        this.addToolbar();
        this.addEventHandlers();
    }

    protected override initializeSprotty(): void {
        if (this.modelSource instanceof DiagramServerProxy) {
            this.modelSource.clientId = this.diagramIdentifier.clientId;
        }
        const model = this.requestModel();
        model.then(res => {
            this.actionDispatcher.dispatch(FitToScreenAction.create([]));
        });
    }

    /**
     * Adds a toolbar to the Sprotty container
     */
    protected addToolbar(): void {
        const containerDiv = document.getElementById(this.diagramIdentifier.clientId + '_container');
        if (containerDiv) {
            const menu = document.createElement("div");
            menu.id = "bigorm-toolbar";
            menu.innerHTML = `
                <div id="toolbar-left">
                    <p id="toolbar-modelName"></p>
                </div>
                <div id="toolbar-right">
                    <div class="vertical-seperator"></div>
                    <vscode-button appearance="icon" id="refresh-button" class="tooltip">
                        <span class="codicon codicon-refresh"></span>
                        <span class="tooltiptext">Refresh Diagram</span>
                    </vscode-button>
                    <vscode-button appearance="icon" id="fit-button" class="tooltip">
                        <span class="codicon codicon-screen-full"></span>
                        <span class="tooltiptext">Fit to Screen</span>
                    </vscode-button>
                    <vscode-button appearance="icon" id="collapseAll-button" class="tooltip">
                        <span class="codicon codicon-collapse-all"></span>
                        <span class="tooltiptext">Collapse All</span>
                    </vscode-button>
                    <vscode-button appearance="icon" id="expandAll-button" class="tooltip-help">
                        <span class="codicon codicon-expand-all"></span>
                        <span class="tooltiptext">Expand All</span>
                    </vscode-button>
                    <div class="vertical-seperator"></div>
                </div>`;

            containerDiv.append(menu);
        }
    }

    /**
     * Adds event handlers to the buttons, by dispatching corresponding events
     */
    protected addEventHandlers(): void {
        (document.getElementById('fit-button') as HTMLElement).addEventListener('click', async () => {
            this.actionDispatcher.dispatch(FitToScreenAction.create([]));
        });
        (document.getElementById('refresh-button') as HTMLElement).addEventListener('click', async () => {
            await this.requestModel().then(res => {
                this.actionDispatcher.dispatch(FitToScreenAction.create([]));
            });
        });
        (document.getElementById('expandAll-button') as HTMLElement).addEventListener('click', async () => {
            await this.actionDispatcher.dispatch(CollapseExpandAllAction.create({expand: true}));
        });
        (document.getElementById('collapseAll-button') as HTMLElement).addEventListener('click', async () => {
            await this.actionDispatcher.dispatch(CollapseExpandAllAction.create({expand: false}));
        });
    }
}
