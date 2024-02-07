import { Action, CollapseExpandAllAction, FitToScreenAction } from "sprotty-protocol";
import { RefreshAction } from "../refresh";

export interface ToolButton {
    id: string;
    label: string;
    icon: string;
    action: Action;
}

export interface ToolButtonDropdown {
    id: string;
    label: string;
    icon: string;
    options: Map<string, string>
}

export interface ToolButtonPanel {
    id: string;
    label: string;
    icon: string;
    selections: Map<string, string>
}

export class RefreshButton implements ToolButton {
    constructor(
        public readonly id = "btn_refresh",
        public readonly label = "Refresh Diagram",
        public readonly icon = "refresh",
        public readonly action = RefreshAction.create()
    ) {}
}

export class FitToScreenButton implements ToolButton {
    constructor(
        public readonly id = "btn_fit_to_screen",
        public readonly label = "Fit to Screen",
        public readonly icon = "screen-full",
        public readonly action = FitToScreenAction.create([])
    ) {}
}

export class ExpandAllButton implements ToolButton {
    constructor(
        public readonly id = "btn_expand_all",
        public readonly label = "Expand All",
        public readonly icon = "expand-all",
        public readonly action = CollapseExpandAllAction.create({ expand: true })
    ) {}
}

export class CollapseAllButton implements ToolButton {
    constructor(
        public readonly id = "btn_collapse_all",
        public readonly label = "Collapse All",
        public readonly icon = "collapse-all",
        public readonly action = CollapseExpandAllAction.create({ expand: false })
    ) {}
}