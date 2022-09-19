import * as vscode from 'vscode';
import { Uri, Webview } from "vscode";
import { SprottyWebviewOptions } from "sprotty-vscode/lib/";
import { SprottyLspWebview } from "sprotty-vscode/lib/lsp";


export class OrmDiagramWebview extends SprottyLspWebview {

    constructor(protected options: SprottyWebviewOptions) {
        super(options);
    }

    protected initializeWebview(webview: vscode.Webview, title?: string) {
        //TODO
    }

    getUri(webview: Webview, extensionUri: Uri, ...pathList: string[]) {
        //TODO
    }
}