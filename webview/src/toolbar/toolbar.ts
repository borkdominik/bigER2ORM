import { inject, injectable } from "inversify";
import { AbstractUIExtension, codiconCSSClasses, IActionDispatcher, TYPES } from "sprotty";
import { createElement, UITypes } from "../utils";
import { CollapseAllButton, ExpandAllButton, FitToScreenButton, RefreshButton, ToolButton } from "./buttons";

@injectable()
export class ToolBar extends AbstractUIExtension {

    @inject(TYPES.IActionDispatcher) protected readonly actionDispatcher: IActionDispatcher;
    static readonly ID = "toolbar-overlay";

    id(): string {
        return ToolBar.ID;
    }

    containerClass(): string {
        return ToolBar.ID;
    }

    protected initializeContents(containerElement: HTMLElement): void {
        containerElement.appendChild(this.createLeftSide());
        containerElement.appendChild(this.createRightSide());
    }

    protected createLeftSide(): HTMLElement {
        const leftSide = createElement("div", ["toolbar-left"]);
        // TODO: improve model name (-> model name is currently set in the view)
        leftSide.appendChild(this.createModelName());
        return leftSide;
    }

    protected createRightSide(): HTMLElement {
        const rightSide = createElement("div", ["toolbar-right"]);
        rightSide.appendChild(this.createSeparator());
        rightSide.appendChild(this.createToolButton(new RefreshButton()));
        rightSide.appendChild(this.createToolButton(new FitToScreenButton()));
        rightSide.appendChild(this.createToolButton(new CollapseAllButton()));
        rightSide.appendChild(this.createToolButton(new ExpandAllButton()));
        rightSide.appendChild(this.createSeparator());
        rightSide.appendChild(this.createHelpButton());
        return rightSide;
    }

    private createToolButton(toolButton: ToolButton): HTMLElement {
        const baseDiv = document.getElementById(this.options.baseDiv);
        if (baseDiv) {
            const button = createElement("div", ["overlay-button", "tooltip"]);
            button.id = `${toolButton.id}-container`;
            const insertedDiv = baseDiv.insertBefore(button, baseDiv.firstChild);
            insertedDiv.appendChild(this.createIcon(toolButton.icon));

            const tooltiptext = createElement("span", ["tooltiptext"]);
            tooltiptext.innerText = toolButton.label;
            insertedDiv.appendChild(tooltiptext);

            insertedDiv.onclick = () => this.actionDispatcher.dispatch(toolButton.action);
            return button;
        }
        return createElement("div");
    }

    private createModelName(): HTMLElement {
        const nameElement = createElement("p");
        nameElement.id = UITypes.MODEL_NAME;
        return nameElement;
    }

    private createHelpButton(): HTMLElement {
        const baseDiv = document.getElementById(this.options.baseDiv);
        if (baseDiv) {
            const button = createElement("div", ["overlay-button", "link-button", "tooltip-help"]);
            const insertedDiv = baseDiv.insertBefore(button, baseDiv.firstChild);
            insertedDiv.appendChild(this.createIcon("question"));

            // tooltip
            const tooltiptext = createElement("span", ["tooltiptext"]);
            tooltiptext.innerText = "Open Help";
            insertedDiv.appendChild(tooltiptext);

            const link = createElement("vscode-link");
            link.appendChild(insertedDiv);
            link.setAttribute("href", UITypes.HELP_LINK);
            return link;
        }
        return createElement("div");
    }

    protected createSeparator(): HTMLElement {
        return createElement("div", ["vertical-separator"]);
    }

    protected createIcon(codiconId: string): HTMLElement {
        return createElement("i", [...codiconCSSClasses(codiconId), "tool-icon"]);
    }
}