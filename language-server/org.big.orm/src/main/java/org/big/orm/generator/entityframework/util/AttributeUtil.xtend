package org.big.orm.generator.entityframework.util

import org.big.orm.ormModel.DataAttribute
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.AttributeType
import com.google.inject.Singleton
import org.big.orm.ormModel.DataType

@Singleton
class AttributeUtil {
	
	def CharSequence compileToEntityFrameworkAttribute(DataAttribute a, Boolean keyAttribute)
	'''
	«IF a.datatype == DataType.STRING»[Column(TypeName = "Varchar(255)")]«ENDIF»
	public «a.compileTypeAndVisiblity(keyAttribute)» «CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, a.name)» { get; set; }
	'''
	
	private def CharSequence compileTypeAndVisiblity(DataAttribute a, Boolean keyAttribute){
		if (keyAttribute) {
			return '''«a.typeString»'''
		} else if (a.type === AttributeType.REQUIRED) {
			return '''required «a.typeString»'''
		} else {
			return '''«a.typeString»?'''
		}
	}
	
	def String getTypeString(DataAttribute a){
		return switch (a.datatype){
				case BOOLEAN: "Boolean"
				case INT: "int"
				case STRING: "string"
				case UUID: "Guid"
			}
	}
}