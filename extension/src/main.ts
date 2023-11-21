import * as vscode from 'vscode';
import { LanguageClient } from 'vscode-languageclient/node';
import { OrmWebviewPanelManager, createLanguageClient, registerCommands } from './orm-lsp-extension';
import { registerDefaultCommands, registerLspEditCommands } from 'sprotty-vscode';

let languageClient: LanguageClient;

export function activate(context: vscode.ExtensionContext) {

	languageClient = createLanguageClient(context);
    registerCommands(context);
    const webviewPanelManager = new OrmWebviewPanelManager({
        extensionUri: context.extensionUri,
        defaultDiagramType: 'bigorm-diagram',
        languageClient,
        supportedFileExtensions: ['.orm']
    });
    
    registerDefaultCommands(webviewPanelManager, context, { extensionPrefix: 'bigorm' });
    registerLspEditCommands(webviewPanelManager, context, { extensionPrefix: 'bigorm' });

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
