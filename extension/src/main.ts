import * as vscode from 'vscode';
import { LanguageClient } from 'vscode-languageclient/node';
import { registerDefaultCommands, registerLspEditCommands } from 'sprotty-vscode';
import { OrmWebviewPanelManager, createLanguageClient, registerCommands } from './orm-lsp-extension';

let languageClient: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
    languageClient = createLanguageClient(context);
    registerCommands(context);
    const webviewViewProvider = new OrmWebviewPanelManager({
        extensionUri: context.extensionUri,
        defaultDiagramType: 'bigorm-diagram',
        languageClient,
        supportedFileExtensions: ['.orm']
    });
    registerDefaultCommands(webviewViewProvider, context, { extensionPrefix: 'bigorm' });
    registerLspEditCommands(webviewViewProvider, context, { extensionPrefix: 'bigorm' });

    const openHelp = 'Open Help';
    vscode.window.showInformationMessage('BigORM Extension is active.', ...[openHelp])
        .then((selection) => {
            if (selection === openHelp) {
                vscode.env.openExternal(vscode.Uri.parse('https://github.com/big-thesis/Stainer.MDE4ORM'));
            }
    });
}

export async function deactivate() {
	if (languageClient) {
        await languageClient.stop();
    }
}