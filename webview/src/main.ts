import 'reflect-metadata';
import 'sprotty-vscode-webview/css/sprotty-vscode.css';
import { Container } from 'inversify';
import { SprottyLspEditStarter } from 'sprotty-vscode-webview/lib/lsp/editing';
import { createOrmDiagramContainer } from './di.config';
import { load as loadLibavoidRouter } from 'sprotty-routing-libavoid';
import { SprottyDiagramIdentifier } from 'sprotty-vscode-webview';

export class OrmSprottyStarter extends SprottyLspEditStarter {

    createContainer(diagramIdentifier: SprottyDiagramIdentifier) {
        console.log("WEBVIEW CALLED!");
        return createOrmDiagramContainer(diagramIdentifier.clientId);
    }

    protected addVscodeBindings(container: Container, diagramIdentifier: SprottyDiagramIdentifier): void {
        console.log("WEBVIEW CALLED!");
        super.addVscodeBindings(container, diagramIdentifier);
    // configureModelElement(container, 'button:create', PaletteButton, PaletteButtonView);
    }
}

console.log("WEBVIEW CALLED!");

loadLibavoidRouter().then(() => {
    console.log("WEBVIEW CALLED!");
    new OrmSprottyStarter();
});