import 'reflect-metadata';
import 'sprotty-vscode-webview/css/sprotty-vscode.css';
import '../css/toolbar.css';
import { Container } from 'inversify';
import { SprottyLspEditStarter } from 'sprotty-vscode-webview/lib/lsp/editing';
import { createDiagramContainer } from './di.config';
import { load as loadLibavoidRouter } from 'sprotty-routing-libavoid';
import { SprottyDiagramIdentifier } from 'sprotty-vscode-protocol';
import { VscodeDiagramServer, VscodeDiagramWidget } from 'sprotty-vscode-webview';
import { OrmDiagramServer } from './diagram-server';
import { OrmDiagramWidget } from './diagram-widget';

export class OrmSprottyStarter extends SprottyLspEditStarter {

    createContainer(diagramIdentifier: SprottyDiagramIdentifier) {
        return createDiagramContainer(diagramIdentifier.clientId);
    }

    protected override addVscodeBindings(container: Container, diagramIdentifier: SprottyDiagramIdentifier): void {
        super.addVscodeBindings(container, diagramIdentifier);
        container.rebind(VscodeDiagramServer).to(OrmDiagramServer);
        container.rebind(VscodeDiagramWidget).to(OrmDiagramWidget).inSingletonScope();
    }
}

loadLibavoidRouter().then(() => {
    new OrmSprottyStarter();
});