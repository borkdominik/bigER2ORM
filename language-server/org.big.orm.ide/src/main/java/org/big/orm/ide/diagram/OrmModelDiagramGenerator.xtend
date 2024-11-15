package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.tracing.ITraceProvider
import org.eclipse.sprotty.xtext.SIssueMarkerDecorator
import com.google.inject.Inject
import org.big.orm.ormModel.OrmModel
import org.eclipse.sprotty.SGraph
import org.eclipse.sprotty.SModelElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.sprotty.SLabel
import static org.big.orm.ormModel.OrmModelPackage.Literals.*
import org.eclipse.sprotty.LayoutOptions
import java.util.ArrayList
import org.big.orm.ormModel.ModelElement
import org.eclipse.sprotty.SCompartment
import org.big.orm.ormModel.Embeddable
import org.eclipse.sprotty.SButton
import org.eclipse.sprotty.IDiagramState
import org.big.orm.ormModel.Attribute
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.Relationship
import org.eclipse.sprotty.SNode
import java.util.List
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.InheritableElement

class OrmModelDiagramGenerator implements IDiagramGenerator {
	
	
	@Inject extension ITraceProvider
	@Inject extension SIssueMarkerDecorator
	
	// Types for the elements
	static val GRAPH = 'graph'
	static val NODE_INHERITABLE = 'node:inheritable'
	static val NODE_RELATIONSHIP = 'node:relationship'
	static val NODE_EMBEDDABLE = 'node:embeddable'
	static val COMP_ELEMENT_HEADER = 'comp:element-header'
	static val RELATIONSHIP_LABEL = 'label:relationship'
	static val ELEMENT_LABEL = 'label:header'
	static val BUTTON_EXPAND = 'button:expand'
	static val COMP_ATTRIBUTES = 'comp:attributes'
	static val COMP_ATTRIBUTE_ROW = 'comp:attribute-row'
	static val ATTRIBUTE_LABEL_TEXT = 'label:text'
	static val ATTRIBUTE_LABEL_KEY = 'label:key'
	static val ATTRIBUTE_LABEL_REQUIRED = 'label:required'
	static val EDGE_RELATIONSHIP = 'edge:relationship'
	static val EDGE_INHERITANCE = 'edge:inheritance'
	
	
	OrmModel model
	SGraph graph
	IDiagramState state
	
	override generate(Context context) {
		System.err.println("OrmModelDiagramGenerator called")
		this.state = context.state
		val contentHead = context.resource.contents.head
		if (contentHead instanceof OrmModel) {
			model = contentHead
			toSGraph(model, context)
		}
		return graph
	}
	
	def toSGraph(OrmModel model, extension Context context) {
		graph = new OrmModelGraph => [
			id = idCache.uniqueId(model, model?.name ?: "undefined")
			type = GRAPH
			name = model.name
			children = new ArrayList<SModelElement>
		]
		graph.traceAndMark(model, context)
		
		//Create and add entities to graph
		graph.children.addAll(model.elements.map[toSNode(context)])
		
		
		// Create Relationship nodes for many to many with additional attributes
		model.relationships.filter[type.equals(RelationshipType.MANY_TO_MANY)].filter[!attributes.empty].forEach[ r |
			graph.children.add(toSNode(r, context));
		]
		
		// Create Relationship nodes and edges
		model.relationships.forEach[ r |
			graph.children.addAll(r.toSEdges(context))
		]
		
		// Create Inheritance edges
		model.elements.filter(InheritableElement).forEach[ e | 
			graph.children.addAll(e.addInheritanceEdge(context))
		]
	}
	
	def List<OrmModelRelationshipEdge> toSEdges(Relationship relationship, extension Context context) {
		var edges = new ArrayList<OrmModelRelationshipEdge>();
		if(relationship.type.equals(RelationshipType.MANY_TO_MANY) && !relationship.attributes.empty){
			val edgeSource = new OrmModelRelationshipEdge [
				sourceId = idCache.getId(relationship)
				targetId = idCache.getId(relationship.source.entity)
				unidirectional = true
				id = idCache.uniqueId(relationship.name + ".source")
				type = EDGE_RELATIONSHIP
			]
			
			val edgeTarget = new OrmModelRelationshipEdge [
				sourceId = idCache.getId(relationship)
				targetId = idCache.getId(relationship.target.entity)
				unidirectional = true
				id = idCache.uniqueId(relationship.name + ".target")
				type = EDGE_RELATIONSHIP
			]
			
			edges.add(edgeSource)
			edges.add(edgeTarget)
		} else {
			val edge = new OrmModelRelationshipEdge [
				sourceId = idCache.getId(relationship.source.entity)
				targetId = idCache.getId(relationship.target.entity)
				unidirectional = relationship.unidirectional
				id = idCache.uniqueId(relationship.name)
				type = EDGE_RELATIONSHIP
			]
		
			edges.add(edge)
		}
		return edges
	}
	
	def List<OrmModelInheritanceEdge> addInheritanceEdge(InheritableElement element, extension Context context) {
		var edges = new ArrayList<OrmModelInheritanceEdge>();
		if (element.extends !== null) {
			edges.add(new OrmModelInheritanceEdge [
				sourceId = idCache.getId(element)
				targetId = idCache.getId(element.extends)
				id = idCache.uniqueId(idCache.getId(element) + ".extends")
				type = EDGE_INHERITANCE
			])
		}
		return edges
	}
	
	
	def SNode toSNode(Relationship relationship, extension Context context) {
		val relationshipId = idCache.uniqueId(relationship, relationship.name + ".node")
		val node = new SNode [
			id = relationshipId
			type = NODE_RELATIONSHIP
			layout = 'vbox'
			children = #[
				(new SLabel [
					id = idCache.uniqueId(relationshipId + '.label')
					text = relationship.name
					type = RELATIONSHIP_LABEL
				]).trace(relationship, RELATIONSHIP__NAME, -1)
			]
		]
		node.layoutOptions = new LayoutOptions [
			paddingFactor = 2.0
		]

		node.traceAndMark(relationship, context)
		return node
	}
	
	def OrmModelNode toSNode(ModelElement element, extension Context context) {
		val elementId = idCache.uniqueId(element, element.name) 
		val elementType = switch(element) {
			case element instanceof InheritableElement : NODE_INHERITABLE
			case element instanceof Embeddable : NODE_EMBEDDABLE
			default : ""
		}
		
		val node = new OrmModelNode [
			id = elementId
			type = elementType
			layout = 'vbox'
			layoutOptions = new LayoutOptions [
				VGap = 10.0
			]
			children = new ArrayList<SModelElement>
		]
		
		val additionalText = switch(element) {
			case element instanceof Embeddable : "[Embeddable] "
			case element instanceof MappedClass : "[MappedClass] "
			default : ""
		}
		
		// Header with label and collapse/expand button
		val headerComp = new SCompartment => [
			id = idCache.uniqueId(elementId + '.header-comp')
			type = COMP_ELEMENT_HEADER
			layout = 'hbox'
			children = #[
				(new SLabel [
					id = idCache.uniqueId(elementId + '.label')
					type = ELEMENT_LABEL
					text = additionalText + element.name
				]).trace(element, MODEL_ELEMENT__NAME, -1),
				(new SButton [
					id = idCache.uniqueId(elementId + '.button')
					type = BUTTON_EXPAND
				])
			]
		]
		node.children.add(headerComp)
		
		// Create attributes if element is expanded
		if (state.expandedElements.contains(elementId) || state.currentModel.type == 'NONE') {
			val comp = new SCompartment => [
				id = elementId + '.attributes'
				type = COMP_ATTRIBUTES
				layout = 'vbox'
				layoutOptions = new LayoutOptions [
					HAlign = 'left'
					VGap = 1.0
				]
				children = new ArrayList<SModelElement>
			]
			comp.children.addAll(element.attributes.map[createAttributeLabels(elementId, context)])
			
			model.relationships.filter[source.entity.name.equals(element.name)].forEach[ r |
				comp.children.add(r.createPortForRelationshipSource(elementId, context));
			]
			
			model.relationships.filter[target.entity.name.equals(element.name)].filter[!unidirectional].forEach[ r |
				comp.children.add(r.createPortForRelationshipTarget(elementId, context));
			]
			node.children.add(comp)
			

			
			state.expandedElements.add(elementId)
			node.expanded = true
		} else {
			node.expanded = false
		}
		
		node.traceAndMark(element, context)
		return node
	}
	
	
	def SCompartment createPortForRelationshipSource(Relationship relationship, String elementId, extension Context context) {
		val sourceId = idCache.uniqueId(relationship.source, elementId + '.' + relationship.source.attributeName)
		val comp = new SCompartment => [
			id = sourceId
			type = COMP_ATTRIBUTE_ROW
			layout = 'hbox'
			layoutOptions = new LayoutOptions [
				VAlign = 'middle'
				HGap = 5.0
			]
			children = #[
				(new SLabel [
					id = sourceId + '.name'
					text = relationship.source.attributeName
					type = ATTRIBUTE_LABEL_TEXT
				]).trace(relationship.source, ATTRIBUTE__NAME, -1),
				(new SLabel [
					id = sourceId + ".datatype"
					text = relationship.target.entity.name + (relationship.type.equals(RelationshipType.MANY_TO_MANY) ? "[]" : "")
					type = ATTRIBUTE_LABEL_TEXT
				])
			]
		]
		comp.traceAndMark(relationship.source, context)
		return comp
	}
	
	def SCompartment createPortForRelationshipTarget(Relationship relationship, String elementId, extension Context context) {
		val targetId = idCache.uniqueId(relationship.target, elementId + '.' + relationship.target.attributeName)
		val comp = new SCompartment => [
			id = targetId
			type = COMP_ATTRIBUTE_ROW
			layout = 'hbox'
			layoutOptions = new LayoutOptions [
				VAlign = 'middle'
				HGap = 5.0
			]
			children = #[
				(new SLabel [
					id = targetId + '.name'
					text = relationship.target.attributeName
					type = ATTRIBUTE_LABEL_TEXT
				]).trace(relationship.target, ATTRIBUTE__NAME, -1),
				(new SLabel [
					id = targetId + ".datatype"
					text = relationship.source.entity.name + (relationship.type.equals(RelationshipType.MANY_TO_ONE) || relationship.type.equals(RelationshipType.MANY_TO_MANY) ? "[]" : "")
					type = ATTRIBUTE_LABEL_TEXT
				])
			]
		]
		comp.traceAndMark(relationship.source, context)
		return comp
	}
	
	def SCompartment createAttributeLabels(Attribute attribute, String elementId, extension Context context) {
		val attributeId = idCache.uniqueId(attribute, elementId + '.' + attribute.name)
		val labelType = switch attribute.type {
			case AttributeType.ID: ATTRIBUTE_LABEL_KEY
			case AttributeType.REQUIRED: ATTRIBUTE_LABEL_REQUIRED
			default: ATTRIBUTE_LABEL_TEXT
		}
		val comp = new SCompartment => [
			id = attributeId
			type = COMP_ATTRIBUTE_ROW
			layout = 'hbox'
			layoutOptions = new LayoutOptions [
				VAlign = 'middle'
				HGap = 5.0
			]
			children = #[
				(new SLabel [
					id = attributeId + '.name'
					text = attribute.name
					type = labelType
				]).trace(attribute, ATTRIBUTE__NAME, -1),
				(new SLabel [
					id = attributeId + ".datatype"
					text = attribute.attributeText
					type = labelType
				])
			]
		]
		comp.traceAndMark(attribute, context)
		return comp
	}
	
	def String attributeText(Attribute a) {
		if(a instanceof DataAttribute){
			return a.datatype.toString
		} else if (a instanceof EmbeddedAttribute){
			return a.embeddedType.name
		}
		return ' '
	}


	def <T extends SModelElement> T traceAndMark(T sElement, EObject element, Context context) {
		sElement.trace(element).addIssueMarkers(element, context) 
	}
}