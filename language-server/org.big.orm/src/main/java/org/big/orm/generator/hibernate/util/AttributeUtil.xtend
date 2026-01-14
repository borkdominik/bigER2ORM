package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.DataAttribute
import com.google.common.base.CaseFormat
import java.util.List
import java.util.ArrayList
import org.big.orm.ormModel.EnumAttribute

@Singleton
class AttributeUtil {
	
	def compile(DataAttribute a){
		var List<CharSequence> columnProperties = new ArrayList<CharSequence>()
		columnProperties.add('''name = "«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»"''')
		if (a.type.equals(AttributeType.REQUIRED)) {
			columnProperties.add('''nullable = false''')
		}
		
		'''
		«IF a.type.equals(AttributeType.ID)»
		@Id
		@GeneratedValue(strategy = GenerationType.UUID)
		«ENDIF»
		@Column(«String.join(", ", columnProperties)»)
		private «a.datatype» «a.name»;
		'''
	}
	
	
	def compile(EmbeddedAttribute a)
	'''
	«IF a.type.equals(AttributeType.ID)»
	@EmbeddedId
	«ELSE»
	@Embedded
	«ENDIF»
	private «a.embeddedType.name» «a.name»;
	'''
	
	def compile(EnumAttribute a)
	'''
	@Convert(converter = «a.enumType.name».Converter.class)
	@Column(name = "«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»")
	private «a.enumType.name» «a.name»;
	'''
}