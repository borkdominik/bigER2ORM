package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.LanguageAwareDiagramServer
import org.eclipse.sprotty.Action
import com.google.inject.Inject
import org.eclipse.sprotty.ComputedBoundsApplicator
import org.eclipse.sprotty.ILayoutEngine
import org.eclipse.sprotty.IModelUpdateListener
import org.eclipse.sprotty.IPopupModelFactory
import org.eclipse.sprotty.IDiagramExpansionListener
import org.eclipse.sprotty.IDiagramOpenListener
import org.eclipse.sprotty.IDiagramSelectionListener
import org.eclipse.sprotty.SModelCloner

class OrmModelDiagramServer extends LanguageAwareDiagramServer {
	
	@Inject
	override void setLayoutEngine(ILayoutEngine engine){
		super.setLayoutEngine(engine)
	}
	
	@Inject
	override void setComputedBoundsApplicator(ComputedBoundsApplicator applicator){
		super.setComputedBoundsApplicator(applicator)
	}
	
	@Inject
	override void setModelUpdateListener(IModelUpdateListener listener) {
		super.setModelUpdateListener(listener)
	}
	
	@Inject
	override void setPopupModelFactory(IPopupModelFactory factory) {
		super.setPopupModelFactory(factory)
	}
	
	@Inject
	override void setSelectionListener(IDiagramSelectionListener listener) {
		super.setSelectionListener(listener)
	}
	
	@Inject
	override void setExpansionListener(IDiagramExpansionListener diagramExpansionListener) {
		super.setExpansionListener(diagramExpansionListener)
	}
	
	@Inject
	override void setOpenListener(IDiagramOpenListener diagramOpenListener) {
		super.setOpenListener(diagramOpenListener)
	}
	
	@Inject 
	override void setSModelCloner(SModelCloner smodelCloner) {
		super.setSModelCloner(smodelCloner)
	}

	override protected handleAction(Action action) {
		//TODO: Implement additional actions here
		super.handleAction(action)
	}

}