import { injectable } from "inversify";
import { Action } from 'sprotty-protocol';
import { VscodeLspEditDiagramServer } from "sprotty-vscode-webview/lib/lsp/editing";

@injectable()
export class OrmDiagramServer extends VscodeLspEditDiagramServer {

    /**
     * Check which actions should be handled on the server by returning true. If false,
     * the action is handled locally (slightly counter-intuitive with the method's name).
     */
    override handleLocally(action: Action): boolean {
        return super.handleLocally(action);
    }
}