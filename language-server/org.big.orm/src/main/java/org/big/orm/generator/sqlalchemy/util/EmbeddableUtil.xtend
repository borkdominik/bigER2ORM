package org.big.orm.generator.sqlalchemy.util

import org.big.orm.ormModel.Embeddable
import com.google.inject.Singleton
import com.google.inject.Inject

@Singleton
class EmbeddableUtil {
		
	
	@Inject extension AttributeUtil attributeUtil;
	
	def compile(Embeddable e) 
	'''
	from dataclasses import dataclass
	
	
	@dataclass
	class «e.name»(object):
		«FOR attribute : e.attributes»
		«attribute.compileToDataclassAttribute»
		«ENDFOR»
	'''
}