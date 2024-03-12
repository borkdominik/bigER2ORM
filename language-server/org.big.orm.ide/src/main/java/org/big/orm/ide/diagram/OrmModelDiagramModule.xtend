package org.big.orm.ide.diagram

import org.eclipse.sprotty.IDiagramServer
import org.eclipse.sprotty.ILayoutEngine
import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.DefaultDiagramModule
import org.eclipse.sprotty.ComputedBoundsApplicator

class OrmModelDiagramModule extends DefaultDiagramModule {

	def Class<? extends IDiagramGenerator> bindIDiagramGenerator() {
		OrmModelDiagramGenerator
	}
	
	override Class<? extends IDiagramServer> bindIDiagramServer() {
		OrmModelDiagramServer
	}

	override bindIDiagramServerFactory() {
		OrmModelDiagramServerFactory
	}

	override bindIDiagramExpansionListener() {
		ExpansionListener
	}

	override Class<? extends ILayoutEngine> bindILayoutEngine() {
		OrmModelLayoutEngine
	}
	
	def Class<? extends ComputedBoundsApplicator> bindComputedBoundsApplicator() {
		ComputedBoundsApplicator
	}
}