package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.DefaultDiagramModule
import org.eclipse.sprotty.xtext.IDiagramGenerator

class OrmModelDiagramModule extends DefaultDiagramModule {
	
	def Class<? extends IDiagramGenerator> bindIDiagramGenerator() {
		OrmModelDiagramGenerator
	} 
	
	override bindIDiagramServerFactory() {
		OrmModelDiagramServerFactory
	}
	
	override bindILayoutEngine() {
		OrmModelLayoutEngine
	}
	
	override bindIDiagramServer() {
		OrmModelDiagramServer
	}	
}