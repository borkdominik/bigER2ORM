package org.big.orm.generator.common

import com.google.inject.Singleton
import java.util.List
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.InheritableElement
import org.big.orm.ormModel.Attribute
import org.big.orm.ormModel.EmbeddedAttribute
import java.util.ArrayList
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationEntity
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.ormModel.RelationshipType
import com.google.common.base.CaseFormat

@Singleton
class CommonUtil {
		
	def List<DataAttribute> getKeyAttributesAsDataAttributes(InheritableElement i){
		var Attribute keyAttribute = i.keyAttribute
		if (keyAttribute instanceof EmbeddedAttribute){
			return keyAttribute.embeddedType.attributes.filter(DataAttribute).toList
		} else {
			var ArrayList<DataAttribute> dataAttributeList = new ArrayList<DataAttribute>();
			dataAttributeList.add((keyAttribute as DataAttribute))
			return dataAttributeList
		}
	}
	
	
	def Attribute getKeyAttribute(InheritableElement i){
		var List<Attribute> keyAttributes = i.allAttributes.filter[type === AttributeType.ID].toList
		if (keyAttributes.length != 1) {
			throw new Exception("There should always only be one ID for each inheritable.")
		}
		return keyAttributes.head
	}
	
	
		
	def List<Attribute> getAllAttributes(InheritableElement i) {
		val attributes = new ArrayList<Attribute>()
		attributes.addAll(i.attributes)
		if (i.extends !== null) {
			attributes.addAll(i.extends.allAttributes)
		}
		return attributes
	}
	
		
	def Entity getRootElement(Entity e) {
		if (e.extends !== null && e.extends instanceof Entity) {
			return (e.extends as Entity).rootElement
		}
		return e
	}
	
		
	def Relationship createJoinRelationship(Entity joinEntity, RelationEntity relationEntity) {
		var Relationship relationship = OrmModelFactory.eINSTANCE.createRelationship()
		relationship.type = RelationshipType.MANY_TO_ONE
		relationship.source = OrmModelFactory.eINSTANCE.createRelationEntity()
		relationship.target = OrmModelFactory.eINSTANCE.createRelationEntity()
		relationship.sourceRequired = true
		relationship.source.entity = joinEntity
		relationship.source.attributeName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, relationEntity.entity.name)
		relationship.target.entity = relationEntity.entity
		relationship.target.attributeName = relationEntity.attributeName
		relationship.unidirectional = false
		return relationship
	}
}