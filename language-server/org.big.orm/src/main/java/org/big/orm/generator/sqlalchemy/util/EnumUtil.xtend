package org.big.orm.generator.sqlalchemy.util

import com.google.inject.Singleton
import org.big.orm.ormModel.OrmEnum

@Singleton
class EnumUtil {
	
	def compile(OrmEnum e)
	'''
	from enum import Enum


	class «e.name»(Enum):
		«FOR value : e.values SEPARATOR "\n"»«value.value» = "«value.value»"«ENDFOR»
	'''
}