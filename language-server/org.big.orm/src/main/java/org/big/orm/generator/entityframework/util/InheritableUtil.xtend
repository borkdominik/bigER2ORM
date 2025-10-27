package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import com.google.inject.Inject
import org.big.orm.ormModel.InheritableElement
import com.google.common.base.CaseFormat
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.EnumAttribute
import java.util.List
import org.big.orm.ormModel.DataAttribute

@Singleton
class InheritableUtil {
	
	@Inject extension ImportUtil importUtil;
	@Inject extension CommonUtil commonUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension RelationshipUtil relationshipUtil;
	public String modelName = "";
	
	
	def CharSequence compile(InheritableElement e) 
	'''
   	«FOR i : e.generateImports AFTER "\n"»
   	using «i»;
   	«ENDFOR»
   	namespace «modelName».entity
   	{
   		«IF e.needsTableAnnotation»[Table("«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»")]«ENDIF»
   		«IF !e.keysAsDataAttributesIgnoringInheritance.empty»«e.compilePrimaryKeyAnnotation»«ENDIF»
   		«IF e instanceof Entity && (e as Entity).joinEntity»«(e as Entity).compilePrimaryKeyAnnotationForJoinEntity»«ENDIF»
   		public«IF e instanceof MappedClass» abstract«ENDIF» class «e.name»«IF e.extends !== null» : «e.extends.name»«ENDIF»
   		{
   			«FOR attribute : e.attributes.filter[a | a.type === AttributeType.ID].toList.allAttributesAsDataAttributes SEPARATOR "\n"»
   			«attribute.compileToEntityFrameworkAttribute(true)»
   			«ENDFOR»«IF !e.attributes.filter[a | a.type === AttributeType.ID].toList.allAttributesAsDataAttributes.empty»
   			
   			«ENDIF»
   			«FOR attribute : e.attributes.filter[a | a.type !== AttributeType.ID].toList.allAttributesAsDataAttributes SEPARATOR "\n"»
   			«attribute.compileToEntityFrameworkAttribute(false)»
   			«ENDFOR»«IF !e.attributes.filter[a | a.type !== AttributeType.ID].toList.allAttributesAsDataAttributes.empty»
   			
   			«ENDIF»
   			«FOR attribute : e.attributes.filter(EnumAttribute) SEPARATOR "\n"»
   			«attribute.compileToEntityFrameworkAttribute()»
   			«ENDFOR»«IF !e.attributes.filter(EnumAttribute).empty»
   			
   			«ENDIF»
   			«IF e instanceof Entity»«e.compileRelationshipAttributes»«ENDIF»
   		}
   	}
	'''
	
	
	private def CharSequence compilePrimaryKeyAnnotation(InheritableElement e) {
		return '''[PrimaryKey(«e.keysAsDataAttributesIgnoringInheritance.map[attribute | '''nameof(«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, attribute.name)»)'''].join(", ")»)]'''
	}
	
	private def CharSequence compilePrimaryKeyAnnotationForJoinEntity(Entity e) {
		val List<DataAttribute> keyAttributes = (e.joinSource.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(e.joinSource.entity.name) as DataAttribute] + e.joinTarget.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(e.joinTarget.entity.name) as DataAttribute]).toList
		return '''[PrimaryKey(«keyAttributes.map[attribute | '''nameof(«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, attribute.name)»)'''].join(", ")»)]'''
	}
}