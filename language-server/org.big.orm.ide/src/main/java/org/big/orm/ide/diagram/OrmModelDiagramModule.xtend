package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.DefaultDiagramModule
import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.LanguageAwareDiagramServer

class OrmModelDiagramModule extends DefaultDiagramModule {

	def Class<? extends IDiagramGenerator> bindIDiagramGenerator() {
		OrmModelDiagramGenerator
	}
	
	override bindIDiagramServer() {
		LanguageAwareDiagramServer
	}

	override bindIDiagramServerFactory() {
		OrmModelDiagramServerFactory
	}

	override bindILayoutEngine() {
		OrmModelLayoutEngine
	}

	override bindIDiagramExpansionListener() {
		ExpansionListener
	}

}
