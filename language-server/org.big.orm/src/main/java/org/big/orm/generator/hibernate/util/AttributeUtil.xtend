package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.DataAttribute
import com.google.common.base.CaseFormat
import java.util.List
import java.util.ArrayList
import org.big.orm.ormModel.EnumAttribute
import org.big.orm.ormModel.DataType
import com.google.inject.Inject
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.LengthOption

@Singleton
class AttributeUtil {
	
	@Inject extension CommonUtil commonUtil
	
	def compile(DataAttribute a){
		var List<CharSequence> columnProperties = new ArrayList<CharSequence>()
		columnProperties.add('''name = "«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, a.name)»"''')
		if (a.type.equals(AttributeType.REQUIRED)) {
			columnProperties.add('''nullable = false''')
		}
		if (a.datatype == DataType.DATETIME) {
			columnProperties.add('''columnDefinition = "timestamp without time zone"''')
		}
		if (a.datatype == DataType.STRING) {
			columnProperties.add('''length = «a.stringLength»''')
		}
		
		'''
		«IF a.type.equals(AttributeType.ID)»
		@Id
		«IF a.datatype == DataType.UUID»
		@GeneratedValue(strategy = GenerationType.UUID)
		«ELSEIF a.datatype == DataType.INT»
		@GeneratedValue(strategy = GenerationType.IDENTITY)
		«ENDIF»
		«ENDIF»
		@Column(«String.join(", ", columnProperties)»)
		private «a.datatype.javaType» «a.name»;
		'''
	}
	
	private def String getJavaType(DataType datatype) {
		switch datatype {
			case UUID: "UUID"
			case STRING: "String"
			case INT: "Integer"
			case BOOLEAN: "Boolean"
			case FLOAT: "Double"
			case DATETIME: "LocalDateTime"
		}
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