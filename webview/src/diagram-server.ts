import { injectable } from "inversify";
import { ActionHandlerRegistry, MoveCommand } from "sprotty";
import { Action, LayoutAction } from 'sprotty-protocol';
import { VscodeLspEditDiagramServer } from "sprotty-vscode-webview/lib/lsp/editing";

@injectable()
export class OrmDiagramServer extends VscodeLspEditDiagramServer {

    override initialize(registry: ActionHandlerRegistry): void {
        super.initialize(registry);
        registry.register(MoveCommand.KIND, this);
    }

    /**
     * Check which actions should be handled on the server by returning true. If false,
     * the action is handled locally (slightly counter-intuitive with the method's name).
     */
    override handleLocally(action: Action): boolean {
        switch (action.kind) {
            case MoveCommand.KIND:
                return true;
            default:
                return super.handleLocally(action);
        }
    }
}