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
   		public«IF e instanceof MappedClass» abstract«ENDIF» class «e.name»«IF e.extends !== null» : «e.extends.name»«ENDIF»
   		{
   			«FOR attribute : e.attributes.filter[a | a.type === AttributeType.ID].toList.allAttributesAsDataAttributes SEPARATOR "\n"»
   			«attribute.compileToEntityFrameworkAttribute(true)»
   			«ENDFOR»«IF !e.attributes.filter[a | a.type === AttributeType.ID].toList.allAttributesAsDataAttributes.empty»
   			
   			«ENDIF»
   			«FOR attribute : e.attributes.filter[a | a.type !== AttributeType.ID].toList.allAttributesAsDataAttributes SEPARATOR "\n"»
   			«attribute.compileToEntityFrameworkAttribute(false)»
   			«ENDFOR»«IF !e.attributes.filter[a | a.type === AttributeType.ID].toList.allAttributesAsDataAttributes.empty»
   			
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
}