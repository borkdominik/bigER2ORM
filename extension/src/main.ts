import * as vscode from 'vscode';
import { SprottyLspVscodeExtension } from 'sprotty-vscode/lib/lsp';
import { OrmLspVscodeExtension } from './orm-lsp-extension';

let extension: SprottyLspVscodeExtension;

export function activate(context: vscode.ExtensionContext) {

	extension = new OrmLspVscodeExtension(context);
    const openHelp = 'Open Help';
    vscode.window.showInformationMessage('BigORM Extension is active.', ...[openHelp])
        .then((selection) => {
            if (selection === openHelp) {
                //TODO
                vscode.env.openExternal(vscode.Uri.parse('https://github.com/borkdominik/bigER/wiki/Language'));
            }
    });
}

export function deactivate() {
	if (!extension) {
        return Promise.resolve(undefined);
    }

    return extension.deactivateLanguageClient();
}
