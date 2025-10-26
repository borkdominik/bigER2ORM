package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.Embeddable
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.EntityOption
import org.big.orm.ormModel.InheritanceOption
import org.big.orm.ormModel.InheritanceStrategy
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.InheritableElement
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.EmbeddedAttribute
import com.google.inject.Inject
import org.big.orm.ormModel.AttributedElement
import org.big.orm.ormModel.EnumAttribute

@Singleton
class InheritableUtil {
	
	@Inject extension ImportUtil importUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension RelationshipUtil relationshipUtil;
	
	
	def CharSequence compile(AttributedElement e) 
	'''
    package entity;
    
    «FOR i : e.generateImports»
    import «i»;
    «ENDFOR»
    
    «IF e instanceof Entity»
    @Entity
    «ENDIF»
    «IF e instanceof Embeddable»
    @Embeddable
    «ENDIF»
    «IF e instanceof MappedClass»
    @MappedSuperclass
    «ENDIF»
    @Getter
    @Setter
    «IF e instanceof Entity»
    «FOR entityOption: e.options»
    «entityOption.compileEntityOption»
    «ENDFOR»
    «IF e.extends !== null && e.extends instanceof Entity && !(e.extends as Entity).options.filter(InheritanceOption).filter[option == InheritanceStrategy.JOINED_TABLE || option == InheritanceStrategy.UNDEFINED].empty»
    @PrimaryKeyJoinColumns(value = {}, foreignKey = @ForeignKey(name = "fk_«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»_id"))
    «ENDIF»
    «ENDIF»
    public «IF e instanceof MappedClass»abstract «ENDIF»class «e.name» «IF e instanceof InheritableElement && (e as InheritableElement).extends !== null »extends «(e as InheritableElement).extends.name» «ENDIF»«IF e instanceof Embeddable»implements Serializable «ENDIF»{
    	
    	«FOR a : e.attributes SEPARATOR "\n"»
    	«IF a instanceof DataAttribute»
    	«a.compile»
    	«ENDIF»
    	«IF a instanceof EmbeddedAttribute»
    	«a.compile»
    	«ENDIF»
    	«IF a instanceof EnumAttribute»
    	«a.compile»
    	«ENDIF»
    	«ENDFOR»«IF !e.attributes.empty»
    	
    	«ENDIF»
    	«IF (e instanceof Entity)»
    	«e.compileRelationships»
    	«ENDIF»
    }
	'''
	
	private def compileEntityOption(EntityOption entityOption)
	'''
	«IF entityOption instanceof InheritanceOption»
	@Inheritance(strategy = «entityOption.option.compile»)
	«ENDIF»
	'''
	
		
	private def compile(InheritanceStrategy strategy) {
		switch strategy{
			case InheritanceStrategy.UNDEFINED, 
			case InheritanceStrategy.JOINED_TABLE: "InheritanceType.JOINED"
			case InheritanceStrategy.SINGLE_TABLE: "InheritanceType.SINGLE_TABLE"
			case InheritanceStrategy.TABLE_PER_CLASS: "InheritanceType.TABLE_PER_CLASS"
		}
	}
}