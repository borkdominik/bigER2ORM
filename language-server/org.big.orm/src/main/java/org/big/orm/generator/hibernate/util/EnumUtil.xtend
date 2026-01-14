package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.OrmEnum

@Singleton
class EnumUtil {
	
	def compile(OrmEnum e)
	'''
	package entity;
	
	import entity.util.AbstractEnumConverter;
	
	public enum «e.name» {
		«FOR value : e.values SEPARATOR ",\n"»«value.value»«ENDFOR»;
		
		@jakarta.persistence.Converter
		public static class Converter extends AbstractEnumConverter<«e.name»> {
			public Converter() { super(«e.name».class); }
		}
	}
	'''
}