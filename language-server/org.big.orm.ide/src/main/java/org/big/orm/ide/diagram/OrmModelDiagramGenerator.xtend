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
import java.util.List
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.InheritableElement
import org.big.orm.ormModel.OrmEnum
import org.big.orm.ormModel.AttributedElement
import org.big.orm.ormModel.EnumAttribute
import org.big.orm.ormModel.EnumValue
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.RelationEntity

class OrmModelDiagramGenerator implements IDiagramGenerator {
	
	
	@Inject extension ITraceProvider
	@Inject extension SIssueMarkerDecorator
	
	// Types for the elements
	static val GRAPH = 'graph'
	static val NODE_INHERITABLE = 'node:inheritable'
	static val NODE_EMBEDDABLE = 'node:embeddable'
	static val NODE_ENUM = 'node:enum'
	static val COMP_ELEMENT_HEADER = 'comp:element-header'
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

		model.elements.filter(Entity).filter[joinEntity].forEach[ e |
			graph.children.addAll(e.toSEdges(context))
		]
		
		// Create relationship edges
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
		val edge = new OrmModelRelationshipEdge [
			sourceId = idCache.getId(relationship.source.entity)
			targetId = idCache.getId(relationship.target.entity)
			unidirectional = relationship.unidirectional
			id = idCache.uniqueId(relationship.name)
			type = EDGE_RELATIONSHIP
		]
		
		edges.add(edge)
		return edges
	}
	
	def List<OrmModelRelationshipEdge> toSEdges(Entity joinEntity, extension Context context) {
		var edges = new ArrayList<OrmModelRelationshipEdge>();
		val sourceEdge = new OrmModelRelationshipEdge [
			sourceId = idCache.getId(joinEntity)
			targetId = idCache.getId(joinEntity.joinSource.entity)
			unidirectional = false
			id = idCache.uniqueId(joinEntity.name + ".join.source")
			type = EDGE_RELATIONSHIP
		]
		val targetEdge = new OrmModelRelationshipEdge [
			sourceId = idCache.getId(joinEntity)
			targetId = idCache.getId(joinEntity.joinTarget.entity)
			unidirectional = false
			id = idCache.uniqueId(joinEntity.name + ".join.target")
			type = EDGE_RELATIONSHIP
		]
		
		edges.add(sourceEdge)
		edges.add(targetEdge)		
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
	
	
	def OrmModelNode toSNode(ModelElement element, extension Context context) {
		val elementId = idCache.uniqueId(element, element.name) 
		val elementType = switch(element) {
			case element instanceof InheritableElement : NODE_INHERITABLE
			case element instanceof Embeddable : NODE_EMBEDDABLE
			case element instanceof OrmEnum : NODE_ENUM
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
			case element instanceof OrmEnum : "[Enum] "
			case (element instanceof Entity && (element as Entity).joinEntity) : "[JoinEntity] "
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
			if (element instanceof AttributedElement){
				comp.children.addAll(element.attributes.map[createAttributeLabels(elementId, context)])
			} else if (element instanceof OrmEnum){
				comp.children.addAll(element.values.map[createEnumLabel(elementId, context)])
			}
			
			model.relationships.filter[source.entity.name.equals(element.name)].forEach[ r |
				comp.children.add(r.source.createLabelForRelationship(r.target.entity.name, elementId, (r.type == RelationshipType.MANY_TO_MANY || r.type == RelationshipType.MANY_TO_ONE), context));
			]
			
			model.relationships.filter[target.entity.name.equals(element.name)].filter[!unidirectional].forEach[ r |
				comp.children.add(r.target.createLabelForRelationship(r.source.entity.name, elementId, (r.type == RelationshipType.MANY_TO_MANY), context));
			]
			
			val joinEntities = model.elements.filter(Entity).filter[joinEntity];
			
			joinEntities.filter[joinSource.entity.name.equals(element.name)].forEach [ e |
				comp.children.add(e.joinSource.createLabelForRelationship(e.name, elementId, true, context));
			]
			
			joinEntities.filter[joinTarget.entity.name.equals(element.name)].forEach [ e |
				comp.children.add(e.joinTarget.createLabelForRelationship(e.name, elementId, true, context));
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
	
	def SCompartment createLabelForRelationship(RelationEntity relationEntity, String targetEntityName, String elementId, Boolean manyOnElement, extension Context context) {
		val compId = idCache.uniqueId(relationEntity, elementId + '.' + relationEntity.attributeName)
		val comp = new SCompartment => [
			id = compId
			type = COMP_ATTRIBUTE_ROW
			layout = 'hbox'
			layoutOptions = new LayoutOptions [
				VAlign = 'middle'
				HGap = 5.0
			]
			children = #[
				(new SLabel [
					id = compId + '.name'
					text = relationEntity.attributeName
					type = ATTRIBUTE_LABEL_TEXT
				]).trace(relationEntity, ATTRIBUTE__NAME, -1),
				(new SLabel [
					id = compId + ".datatype"
					text = targetEntityName + (manyOnElement ? "[]" : "")
					type = ATTRIBUTE_LABEL_TEXT
				])
			]
		]
		comp.traceAndMark(relationEntity, context)
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
	
	def SCompartment createEnumLabel(EnumValue attribute, String elementId, extension Context context) {
		val attributeId = idCache.uniqueId(attribute, elementId + '.' + attribute.value)
		val labelType = ATTRIBUTE_LABEL_TEXT
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
					id = attributeId + '.value'
					text = attribute.value
					type = labelType
				]).trace(attribute, ENUM_VALUE__VALUE, -1)
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
		} else if (a instanceof EnumAttribute){
			return a.enumType.name
		}
		return ' '
	}


	def <T extends SModelElement> T traceAndMark(T sElement, EObject element, Context context) {
		sElement.trace(element).addIssueMarkers(element, context) 
	}
}