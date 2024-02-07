import * as path from 'path';
import { SprottyDiagramIdentifier, SprottyWebview } from 'sprotty-vscode';
import { SprottyLspWebview } from 'sprotty-vscode/lib/lsp';
import { LspLabelEditActionHandler, SprottyLspEditVscodeExtension, WorkspaceEditActionHandler } from 'sprotty-vscode/lib/lsp/editing';
import * as vscode from 'vscode';
import { LanguageClient, LanguageClientOptions, ServerOptions, } from "vscode-languageclient/node";
import generateCode from './commands/generate-code';
import reverseToModel from './commands/reverse-to-model';
import { OrmDiagramWebview } from './orm-webview';


export class OrmLspVscodeExtension extends SprottyLspEditVscodeExtension {


    constructor(context: vscode.ExtensionContext) {
        super('bigorm', context);
    }

    override registerCommands() {
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
        return undefined;
    }

    createWebView(identifier: SprottyDiagramIdentifier): SprottyWebview {
        const webview = new OrmDiagramWebview({
            extension: this,
            identifier,
            localResourceRoots: [this.getExtensionFileUri('pack'), this.getExtensionFileUri('node_modules')],
            scriptUri: this.getExtensionFileUri('pack', 'webview.js'),
            singleton: true
        }) as SprottyLspWebview;
        webview.addActionHandler(WorkspaceEditActionHandler);
        webview.addActionHandler(LspLabelEditActionHandler);
        this.singleton=webview;
        console.log(webview);
        return webview;
    }
    
    protected activateLanguageClient(context: vscode.ExtensionContext): LanguageClient {
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
}