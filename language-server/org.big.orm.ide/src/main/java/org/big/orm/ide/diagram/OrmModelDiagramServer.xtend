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
import org.eclipse.sprotty.MoveAction
import org.eclipse.sprotty.SModelRoot
import org.eclipse.sprotty.SModelElement
import org.eclipse.sprotty.SModelIndex
import org.eclipse.sprotty.ElementMove
import org.eclipse.sprotty.BoundsAware
import org.eclipse.sprotty.ComputedBoundsAction
import java.util.ArrayList
import org.eclipse.sprotty.ElementAndBounds
import org.eclipse.sprotty.ElementAndAlignment

class OrmModelDiagramServer extends LanguageAwareDiagramServer {

	@Inject
	override void setLayoutEngine(ILayoutEngine engine) {
		super.setLayoutEngine(engine)
	}

	@Inject
	override void setComputedBoundsApplicator(ComputedBoundsApplicator applicator) {
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
		switch action.kind {
			case MoveAction.KIND: this.handle(action as MoveAction)
			default: super.handleAction(action)
		}
	}

	def protected void handle(MoveAction action) {
		if (!action.finished) {
			return;
		}
		
		var ElementMove move = action.moves.get(0)
		var SModelRoot model = getModel();
		var SModelElement element = SModelIndex.find(model, move.elementId);

		if (element instanceof BoundsAware) {

			var BoundsAware bae = element as BoundsAware;
			var ComputedBoundsAction boundsAction = new ComputedBoundsAction();
			var ElementAndBounds newBounds = new ElementAndBounds();
			newBounds.elementId = move.elementId;
			newBounds.newPosition = move.toPosition;
			newBounds.newSize = bae.size;
			boundsAction.bounds = new ArrayList<ElementAndBounds>();
			boundsAction.alignments = new ArrayList<ElementAndAlignment>();
			boundsAction.bounds.add(newBounds);
			boundsAction.revision = model.revision;

			updateModel(this.handle(boundsAction), action);
		}
	}

}
