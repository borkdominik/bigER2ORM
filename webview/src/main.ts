import 'reflect-metadata';
import 'sprotty-vscode-webview/css/sprotty-vscode.css';
import '../css/menu-bar.css';
import { Container } from 'inversify';
import { SprottyLspEditStarter } from 'sprotty-vscode-webview/lib/lsp/editing';
import { createOrmDiagramContainer } from './di.config';
import { load as loadLibavoidRouter } from 'sprotty-routing-libavoid';
import { SprottyDiagramIdentifier, VscodeDiagramWidget } from 'sprotty-vscode-webview';
import { OrmToolbarDiagramWidget } from './toolbar';

export class OrmSprottyStarter extends SprottyLspEditStarter {

    createContainer(diagramIdentifier: SprottyDiagramIdentifier) {
        return createOrmDiagramContainer(diagramIdentifier.clientId);
    }

    protected addVscodeBindings(container: Container, diagramIdentifier: SprottyDiagramIdentifier): void {
        super.addVscodeBindings(container, diagramIdentifier);
        container.rebind(VscodeDiagramWidget).to(OrmToolbarDiagramWidget).inSingletonScope();
    }
}

loadLibavoidRouter().then(() => {
    new OrmSprottyStarter();
});