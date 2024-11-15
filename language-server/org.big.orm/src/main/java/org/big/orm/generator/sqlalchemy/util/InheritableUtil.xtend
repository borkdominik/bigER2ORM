package org.big.orm.generator.sqlalchemy.util

import org.eclipse.emf.ecore.resource.Resource
import org.big.orm.ormModel.InheritableElement
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.InheritanceStrategy
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.EmbeddedAttribute
import java.util.ArrayList
import java.util.List
import com.google.common.base.CaseFormat
import com.google.inject.Singleton
import com.google.inject.Inject
import org.big.orm.ormModel.Attribute

@Singleton
class InheritableUtil {
	
	Resource resource
	
	@Inject extension ImportUtil importUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension RelationshipUtil relationshipUtil;
	
	
	def setResource(Resource resource){
		this.resource = resource
	}
	
	
	def compile(InheritableElement e) 
	'''
	«FOR i : e.generateImports»
	«i»
	«ENDFOR»
	
	
	«IF (e instanceof MappedClass)»@declarative_mixin«ENDIF»
	class «e.name»«e.compileInheritanceDefinition»:
		«IF (e instanceof Entity) && (!((e as Entity).inheritanceStrategy === InheritanceStrategy.SINGLE_TABLE) || (e as Entity).rootElement === e)»
		__tablename__ = '«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»'
		
		«ENDIF»
		«IF (e instanceof Entity) && (e as Entity).inheritanceStrategy === InheritanceStrategy.TABLE_PER_CLASS»
		«(e as Entity).compileTablePerClassInheritedAttributes»
		«ENDIF»
		«IF (e instanceof Entity) && (e as Entity).inheritanceStrategy === InheritanceStrategy.JOINED_TABLE»
		«(e as Entity).compileJoinedTableInheritedAttributes»
		«ENDIF»
		«FOR a : e.attributes.filter(DataAttribute)»
		«a.compileToSqlAlchemyAttribute»
		«ENDFOR»
		«FOR a : e.attributes.filter(EmbeddedAttribute)»
		
		«a.compileToSqlAlchemyAttribute»
		«ENDFOR»
		«IF (e instanceof Entity)»
		«e.compileEntityBody»
		«ENDIF»
	'''
	
	def CharSequence compileEntityBody(Entity e)
	'''
	«e.compileRelationships»
	«e.compileEntityInheritance»
	'''
	
	def CharSequence compileEntityInheritance(Entity e) {
		switch e.inheritanceStrategy {
			case InheritanceStrategy.UNDEFINED, 
			case InheritanceStrategy.JOINED_TABLE:
				e.compileJoinedTableInheritance
			case InheritanceStrategy.SINGLE_TABLE:
				e.compileSingleTableInheritance
			case InheritanceStrategy.TABLE_PER_CLASS:
				e.compileTablePerClassInheritanceArgs
			default: ''''''
		}
	}
	
	private def CharSequence compileSingleTableInheritance (Entity e) {		
		if (e.rootElement === e && !resource.allContents.toIterable.filter(Entity).filter[elem | elem.extends === e].empty) {
			'''
			dtype: Mapped[str] = mapped_column(String(31), nullable=False)
			
			__mapper_args__ = {
				"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»",
				"polymorphic_on": dtype,
			}
			'''
		} else {
			'''
			
			__mapper_args__ = {
				"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»"
			}
			'''
		}
	}
	
	private def CharSequence compileJoinedTableInheritedAttributes (Entity e) {
		if (e.rootElement !== e) {
			var Attribute keyAttribute = e.keyAttribute;
			if (keyAttribute instanceof DataAttribute) {
				'''
				«keyAttribute.compileToSqlAlchemyAttribute»
				'''
			} else if (keyAttribute instanceof EmbeddedAttribute) {
				'''
				«keyAttribute.compileToSqlAlchemyAttribute»
				'''
			}
		} else {
			''''''
		}
	}
	
	private def CharSequence compileJoinedTableInheritance (Entity e) {
		if (e.rootElement !== e){
			var List<String> lowUnderKeyAttributeNames = e.keyAttributesAsDataAttributes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]
			var String lowUnderEntityName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)
			'''
			__mapper_args__ = {
				"polymorphic_identity": "«lowUnderEntityName»",
				"inherit_condition": «String.join(" and ", lowUnderKeyAttributeNames.map[name | "(" + name + " == " + e.rootElement.name + "." + name + ")"])»
			}
			
			__table_args__ = (
				ForeignKeyConstraint([«String.join(", ", lowUnderKeyAttributeNames)»], [«String.join(", ", lowUnderKeyAttributeNames.map[name | e.rootElement.name + "." + name])»], name="fk_«lowUnderEntityName»_id"),
			)
			'''
		} else {
			''''''
		}
	}
	
	private def CharSequence compileTablePerClassInheritanceArgs (Entity e) {
		if (e.extends !== null) {
			'''

			__mapper_args__ = {"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»"«(e.rootElement !== e) ? ", \"concrete\": True"»}
			'''
		} else {
			''''''
		}
	}
	
	private def CharSequence compileTablePerClassInheritedAttributes (Entity e) {
		if (e.extends !== null) {
			'''
			# TODO: Currently inheriting all attributes, as inheritance is buggy with ConcreteClasses
			«FOR a : e.extends.combineInheritedAttributes»
			«a»
			«ENDFOR»
			'''
		} else {
			''''''
		}
	}
	
	def Entity getRootElement(Entity e) {
		if (e.extends !== null && e.extends instanceof Entity) {
			return (e.extends as Entity).rootElement
		}
		return e
	}
	
	
	private def List<CharSequence> combineInheritedAttributes(InheritableElement i)
	{
		val attributes = new ArrayList<CharSequence>()
		if (i.extends !== null) {
			attributes.addAll(i.extends.combineInheritedAttributes)
			attributes.add('''
			''')
		}
		
		for (attribute : i.attributes.filter(DataAttribute)) {
			attributes.add(attribute.compileToSqlAlchemyAttribute)
		}
		
		for (attribute : i.attributes.filter(EmbeddedAttribute)) {
			attributes.add(attribute.compileToSqlAlchemyAttribute)
		}
		return attributes
	}
	
	private def compileInheritanceDefinition(InheritableElement a) {
		if (a instanceof Entity) {
			var InheritanceStrategy strategy = a.inheritanceStrategy
			if (a === a.rootElement) {
				if (strategy === InheritanceStrategy.TABLE_PER_CLASS) {
					return "(ConcreteBase, Base)"
				} else {
					if (a.extends !== null && a.extends instanceof MappedClass) {
						return "(Base, " + a.extends.name + ")"
					} else {
						return "(Base)"
					}
				}
			} else {
				return "(" + a.extends.name + ")"
			}
		} else {
			return ""
		}
	}
}