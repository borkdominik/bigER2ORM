package org.big.orm.generator.sqlalchemy.util

import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.Attribute
import org.big.orm.ormModel.EmbeddedAttribute
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.AttributeType
import com.google.inject.Singleton
import java.util.ArrayList
import java.util.List
import org.big.orm.ormModel.DataType
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.EnumAttribute

@Singleton
class AttributeUtil {
	
	def compileToSqlAlchemyAttribute(Attribute a, Entity columnPropertyForEntity){
		if (a instanceof DataAttribute) {
			a.compileToSqlAlchemyAttribute(columnPropertyForEntity)
		} else if (a instanceof EmbeddedAttribute) {
			a.compileToSqlAlchemyAttribute(columnPropertyForEntity)
		} else if (a instanceof EnumAttribute) {
			a.compileToSqlAlchemyAttribute(columnPropertyForEntity)
		}
	}
	
	private def compileToSqlAlchemyAttribute(DataAttribute a, Entity columnPropertyForEntity)
	'''
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.typeString»] = «a.dataAttributeToMappedColumn(columnPropertyForEntity, a.type===AttributeType.ID, false, (a.type===AttributeType.ID && a.datatype===DataType.UUID), a.type===AttributeType.NONE)»
	'''
	
	def compileToSqlAlchemyAttribute(EmbeddedAttribute a, Entity columnPropertyForEntity){
		if(a.type === AttributeType.ID){
			'''
			«FOR attribute : a.embeddedType.attributes»
			«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)»: Mapped[«(attribute as DataAttribute).typeString»] = «(attribute as DataAttribute).dataAttributeToMappedColumn(columnPropertyForEntity, true, true, false, false)»
			«ENDFOR»
			«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.embeddedType.name»] = composite(«String.join(", ", a.embeddedType.attributes.filter(DataAttribute).map[value | '''"«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, value.name)»"'''])»)
			'''
		} else {
			'''
			«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.embeddedType.name»] = composite(
					«FOR attribute : a.embeddedType.attributes.filter(DataAttribute) SEPARATOR ","»
					«attribute.dataAttributeToMappedColumn(null, false, true, false, a.type===AttributeType.NONE)»
					«ENDFOR»
			)
			'''
		}
	}
	
	private def compileToSqlAlchemyAttribute(EnumAttribute a, Entity columnPropertyForEntity)
	'''
	«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»: Mapped[«a.enumType.name»] = mapped_column(Enum(native_enum=False, length=255), nullable=True)
	'''


	private def dataAttributeToMappedColumn(DataAttribute a, Entity columnPropertyForEntity, Boolean id, Boolean compileName, Boolean autoGenerateID, Boolean nullable){
		if (columnPropertyForEntity !== null) {
			'''column_property(mapped_column(«a.compileDataAttributeMappedColumnProperties(id, compileName, autoGenerateID, nullable)»), «columnPropertyForEntity.name».«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»)'''
		} else {
			'''mapped_column(«a.compileDataAttributeMappedColumnProperties(id, compileName, autoGenerateID, nullable)»)'''
		}
	}
	
	private def compileDataAttributeMappedColumnProperties(DataAttribute a, Boolean id, Boolean compileName, Boolean autoGenerateID, Boolean nullable){
		var List<CharSequence> properties = new ArrayList<CharSequence>();
		if (compileName){
			properties.add('''"«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»"''')
		}
		properties.add(a.mappedTypeString)
		if (id){
			properties.add('''primary_key=True''')
		}
		if(autoGenerateID){
			properties.add('''default=uuid.uuid4()''')
		}
		if(nullable){
			properties.add('''nullable=True''')
		}
		'''«FOR property : properties SEPARATOR ", "»«property»«ENDFOR»'''	
	}
	
		
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
}