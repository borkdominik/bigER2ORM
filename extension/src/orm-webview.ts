import * as vscode from 'vscode';
import { SprottyDiagramIdentifier, WebviewContainer } from "sprotty-vscode/lib/";


export function createWebviewHtml(identifier: SprottyDiagramIdentifier, container: WebviewContainer, options: { scriptUri: vscode.Uri, extensionBaseUri: vscode.Uri, title: string; }): string {
    const transformUri = (uri: vscode.Uri) => container.webview.asWebviewUri(uri).toString();
    const codiconsUri = transformUri(vscode.Uri.joinPath(options.extensionBaseUri, 'node_modules', '@vscode', 'codicons', 'dist', 'codicon.css'));
    const toolkitUri = transformUri(vscode.Uri.joinPath(options.extensionBaseUri, 'node_modules', '@vscode', 'webview-ui-toolkit', 'dist', 'toolkit.js'));
    const webviewScriptUri = transformUri(vscode.Uri.joinPath(options.scriptUri));
    return `
            <!DOCTYPE html>
            <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, height=device-height">
                    <title>${options.title}</title>
                    <link
                        rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css"
                        integrity="sha384-UHRtZLI+pbxtHCWp1t77Bi1L4ZtiqrqD80Kn4Z8NTSRyMA2Fd33n5dQ8lWUE00s/"
                        crossorigin="anonymous">
                    <link href="${codiconsUri}" rel="stylesheet" />    
                    <script type="module" src="${toolkitUri}"></script>
                </head>
                <body>
                    <div id="${identifier.clientId}_container" style="height: 100%;"></div>
                    <script src="${webviewScriptUri}"></script>
                </body>
            </html>`;
}