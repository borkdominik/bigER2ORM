package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import org.big.orm.ormModel.OrmEnum
import com.google.inject.Inject

@Singleton
class EnumUtil {
	
	@Inject extension InheritableUtil inheritableUtil;
	
	def compile(OrmEnum e)
	'''
	namespace «inheritableUtil.modelName».entity
	{
		public enum «e.name»
		{
			«FOR value : e.values SEPARATOR ",\n"»«value.value»«ENDFOR»
		}
	}
	'''	
}