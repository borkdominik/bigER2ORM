package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.DiagramServerFactory
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.sprotty.IDiagramServer

class OrmModelDiagramServerFactory extends DiagramServerFactory {

	@Inject Provider<IDiagramServer> diagramServerProvider

	override getDiagramTypes() {
		#['bigorm-diagram']
	}
	
	override IDiagramServer createDiagramServer(String diagramType, String clientId) {
		val server = diagramServerProvider.get
		server.clientId = clientId
		if (server instanceof OrmModelDiagramServer) {
			server.diagramType = diagramType
		}
		return server
	}
}