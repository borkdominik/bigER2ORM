import * as path from 'path';
import * as vscode from 'vscode';
//import { LspLabelEditActionHandler, SprottyLspEditVscodeExtension, WorkspaceEditActionHandler } from "sprotty-vscode/lib/lsp/editing";
import { LanguageClient, ServerOptions, LanguageClientOptions, } from "vscode-languageclient/node";
//import { SprottyWebview } from "sprotty-vscode/lib/sprotty-webview";
//import { SprottyDiagramIdentifier, SprottyLspWebview } from "sprotty-vscode/lib/lsp";
//import { OrmDiagramWebview } from './orm-webview';
import generateCode from './commands/generate-code';
import reverseToModel from './commands/reverse-to-model';
import { LspWebviewEndpoint, LspWebviewPanelManager } from 'sprotty-vscode/lib/lsp';
import { SprottyDiagramIdentifier } from 'sprotty-vscode';
import { addLspLabelEditActionHandler, addWorkspaceEditActionHandler } from 'sprotty-vscode/lib/lsp/editing';


/* 
constructor(context: vscode.ExtensionContext) {
    super('bigorm', context);
}

protected registerCommands() {
    super.registerCommands();
    this.context.subscriptions.push(vscode.commands.registerCommand('bigorm.model.generateCode', (...commandArgs: any[]) => {
        generateCode();
    }));
    this.context.subscriptions.push(vscode.commands.registerCommand('bigorm.model.reverseToModel', (...commandArgs: any[]) => {
        reverseToModel();
    }));
}

protected getDiagramType(commandArgs: any[]): string | undefined {
    if (commandArgs.length === 0 || (commandArgs[0] instanceof vscode.Uri && commandArgs[0].path.endsWith('.orm'))) {
        return 'bigorm-diagram';
    }
}

createWebView(identifier: SprottyDiagramIdentifier): SprottyWebview {
    const webview = new OrmDiagramWebview({
        extension: this,
        identifier,
        localResourceRoots: [this.getExtensionFileUri('pack'), this.getExtensionFileUri('node_modules')],
        scriptUri: this.getExtensionFileUri('pack', 'webview.js'),
        singleton: false
    }) as SprottyLspWebview;
    webview.addActionHandler(WorkspaceEditActionHandler);
    webview.addActionHandler(LspLabelEditActionHandler);
    console.log(webview)
    return webview;
}
 */
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
    //OLD: context.subscriptions.push(languageClient.start());
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
}