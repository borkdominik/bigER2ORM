package org.big.orm.generator.sqlalchemy.util

import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.Attribute
import org.big.orm.ormModel.EmbeddedAttribute
import java.util.List
import org.big.orm.ormModel.InheritableElement
import java.util.ArrayList
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.Embeddable
import com.google.inject.Singleton

@Singleton
class AttributeUtil {
	
	def compileToSqlAlchemyAttribute(DataAttribute a)
	'''
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.typeString»] = mapped_column(«a.mappedTypeString»«a.additionalAttributeTypeProperties»)
	'''
	
	def compileToSqlAlchemyAttribute(EmbeddedAttribute a)
	'''
	«IF a.type === AttributeType.ID»
	«FOR attribute : a.embeddedType.attributes»
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)»: Mapped[«(attribute as DataAttribute).typeString»] = «(attribute as DataAttribute).embeddedDataAttributeToMappedColumn(true)»
	«ENDFOR»
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.embeddedType.name»] = composite(«String.join(", ", a.embeddedType.attributes.filter(DataAttribute).map[value | "\"" + CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, value.name) + "\""])»)
	«ELSE»
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.embeddedType.name»] = composite(«a.embeddedType.compileCombinedCompositeColumns»)
	«ENDIF»
	'''
	
	private def compileCombinedCompositeColumns(Embeddable e)
	'''«e.attributes.filter(DataAttribute).map[value | value.embeddedDataAttributeToMappedColumn(false)].join(",\n		")»'''
	
	
	private def embeddedDataAttributeToMappedColumn(DataAttribute a, Boolean id)
	'''mapped_column("«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»", «a.mappedTypeString»«IF id», primary_key=True«ELSE», nullable=True«ENDIF»)'''
	
		
	def compileToDataclassAttribute(Attribute a)
	'''
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: «a.typeString»
	'''
	
	
	def String getMappedTypeString(DataAttribute a){
		return switch (a.datatype){
				case BOOLEAN: "Boolean"
				case INT: "Integer"
				case STRING: "String(255)"
				case UUID: "UUID(as_uuid=True)"
			}
	}
	
	def String getAdditionalAttributeTypeProperties(DataAttribute a){
		return switch (a.type){
				case NONE: ", nullable=True"
				case ID: ", primary_key=True, default=uuid.uuid4()"
				case REQUIRED: ""
			}
	}
	
	def String getTypeString(Attribute a){
		if (a instanceof EmbeddedAttribute){
			return a.embeddedType.name
		} else if (a instanceof DataAttribute) {
			return switch (a.datatype){
				case BOOLEAN: "bool"
				case INT: "int"
				case STRING: "str"
				case UUID: "uuid.UUID"
			}
		}
	}
	
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
}