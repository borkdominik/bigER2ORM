import * as path from 'path';
import { SprottyDiagramIdentifier, createFileUri, createWebviewTitle } from 'sprotty-vscode';
import * as vscode from 'vscode';
import generateCode from './commands/generate-code';
import reverseToModel from './commands/reverse-to-model';
import { LanguageClient, LanguageClientOptions, ServerOptions } from 'vscode-languageclient/node';
import { LspWebviewEndpoint, LspWebviewPanelManager } from 'sprotty-vscode/lib/lsp';
import { addLspLabelEditActionHandler, addWorkspaceEditActionHandler } from 'sprotty-vscode/lib/lsp/editing';
import { createWebviewHtml } from './orm-webview';


export function createLanguageClient(context: vscode.ExtensionContext): LanguageClient {
    const executable = process.platform === 'win32' ? 'orm-language-server.bat' : 'orm-language-server';
    const languageServerPath = path.join('server', 'orm-language-server', 'bin', executable);
    const serverLauncher = context.asAbsolutePath(languageServerPath);
    const serverOptions: ServerOptions = {
        run: {
            command: serverLauncher,
            args: ['-trace']
        },
        debug: {
            command: serverLauncher,
            args: ['-trace']
        }
    };
    const clientOptions: LanguageClientOptions = {
        documentSelector: [{
            scheme: 'file',
            language: 'bigorm'
        }]
    };
    const languageClient = new LanguageClient('ormLanguageClient', 'ORM Language Server', serverOptions, clientOptions);
    languageClient.start();
    return languageClient;
}

export function registerCommands(context: vscode.ExtensionContext) {
    context.subscriptions.push(vscode.commands.registerCommand('bigorm.model.generateCode', (...commandArgs: any[]) => {
        generateCode();
    }));
    context.subscriptions.push(vscode.commands.registerCommand('bigorm.model.reverseToModel', (...commandArgs: any[]) => {
        reverseToModel();
    }));
}


export class OrmWebviewPanelManager extends LspWebviewPanelManager  {
    protected override createEndpoint(identifier: SprottyDiagramIdentifier): LspWebviewEndpoint {
        const endpoint = super.createEndpoint(identifier);
        addWorkspaceEditActionHandler(endpoint);
        addLspLabelEditActionHandler(endpoint);
        return endpoint;
    }

    protected override createWebview(identifier: SprottyDiagramIdentifier): vscode.WebviewPanel {
        const extensionPath = this.options.extensionUri.fsPath;

        return this.createWebviewPanel(identifier, {
            localResourceRoots: [ createFileUri(extensionPath, 'pack') ],
            scriptUri: createFileUri(extensionPath, 'pack', 'webview.js'),
            extensionBaseUri: createFileUri(extensionPath)
        });
    }

    // Copies webview-utils.ts/createWebviewPanel, as no other way to inject custom HTML on sprotty-vscode 1.0.0, this is fixed on master branch
    // TODO: replace once new sprotty-vscode release is available
    protected createWebviewPanel(identifier: SprottyDiagramIdentifier,
        options: { localResourceRoots: vscode.Uri[], scriptUri: vscode.Uri, extensionBaseUri: vscode.Uri }): vscode.WebviewPanel {
        options.localResourceRoots.push(vscode.Uri.joinPath(options.extensionBaseUri, "node_modules"));
        const title = createWebviewTitle(identifier);
        const diagramPanel = vscode.window.createWebviewPanel(
            identifier.diagramType || 'diagram',
            title,
            vscode.ViewColumn.Beside,
            {
                localResourceRoots: options.localResourceRoots,
                enableScripts: true,
                retainContextWhenHidden: true
            });
        diagramPanel.webview.html = createWebviewHtml(identifier, diagramPanel, {
            scriptUri: options.scriptUri,
            extensionBaseUri: options.extensionBaseUri,
            title
        });
        return diagramPanel;
    }

}