package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.tracing.ITraceProvider
import org.eclipse.sprotty.xtext.SIssueMarkerDecorator
import com.google.inject.Inject
import org.big.orm.ormModel.OrmModel
import org.eclipse.sprotty.SGraph
import org.eclipse.sprotty.SModelElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.sprotty.SNode
import org.big.orm.ormModel.Entity
import org.eclipse.sprotty.SLabel
import static org.big.orm.ormModel.OrmModelPackage.Literals.*
import org.eclipse.sprotty.SPort
import org.eclipse.sprotty.LayoutOptions
import java.util.ArrayList
import org.big.orm.ormModel.ModelElement

class OrmModelDiagramGenerator implements IDiagramGenerator {
	
	
	@Inject extension ITraceProvider
	@Inject extension SIssueMarkerDecorator
	
	OrmModel model
	SGraph graph
	
	override generate(Context context) {
		System.err.println("OrmModelDiagramGenerator called")
		val contentHead = context.resource.contents.head
		if (contentHead instanceof OrmModel) {
			System.err.println("Generating diagram for model with URI '" + context.resource.URI.lastSegment + "'")
			model = contentHead
			toSGraph(model, context)
		}
		return graph
	}
	
	def toSGraph(OrmModel model, extension Context context) {
		graph = new SGraph => [
			id = idCache.uniqueId(model, model?.name ?: "undefined")
			children = new ArrayList<SModelElement>
		]
		graph.traceAndMark(model, context)
		graph.children.addAll(model.elements.map[toSNode(context)])
	}
	
	def SNode toSNode(ModelElement element, extension Context context) {
		val theId = idCache.uniqueId(element, (element as Entity).name) 
		val node = new SNode [
			id = theId
			children =  #[
				(new SLabel [
					id = idCache.uniqueId(theId + '.label')
					text = (element as Entity).name 
				]).trace(element, MODEL_ELEMENT__NAME, -1),
				new SPort [
					id = idCache.uniqueId(theId + '.newTransition')
				]				
			]
			layout = 'stack'
			layoutOptions = new LayoutOptions [
				paddingTop = 10.0
				paddingBottom = 10.0
				paddingLeft = 10.0
				paddingRight = 10.0
				
			]
		]
		node.traceAndMark(element, context)
		return node
	}
	
//	def SEdge toSEdge(Transition transition, extension Context context) {
//		(new SEdge [
//			sourceId = idCache.getId(transition.eContainer) 
//			targetId = idCache.getId(transition.state)
//			val theId = idCache.uniqueId(transition, sourceId + ':' + transition.event.name + ':' + targetId)
//			id = theId 
//			children = #[
//				(new SLabel [
//					id = idCache.uniqueId(theId + '.label')
//					type = 'label:xref'
//					text = transition.event.name
//				]).trace(transition, StatesPackage.Literals.TRANSITION__EVENT, -1)
//			]
//		]).traceAndMark(transition, context)
//	}


	def <T extends SModelElement> T traceAndMark(T sElement, EObject element, Context context) {
		sElement.trace(element).addIssueMarkers(element, context) 
	}
}