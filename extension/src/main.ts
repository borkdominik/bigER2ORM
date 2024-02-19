import * as vscode from 'vscode';
import { OrmLspVscodeExtension } from './orm-lsp-extension';
import { SprottyLspVscodeExtension } from 'sprotty-vscode/lib/lsp';

let extension: SprottyLspVscodeExtension;

export function activate(context: vscode.ExtensionContext) {

	extension = new OrmLspVscodeExtension(context);
    const openHelp = 'Open Help';
    vscode.window.showInformationMessage('BigORM Extension is active.', ...[openHelp])
        .then((selection) => {
            if (selection === openHelp) {
                vscode.env.openExternal(vscode.Uri.parse('https://github.com/big-thesis/Stainer.MDE4ORM'));
            }
    });
}

export function deactivate() {
	if (!extension) {
        return Promise.resolve(undefined);
    }

    return extension.deactivateLanguageClient();
}