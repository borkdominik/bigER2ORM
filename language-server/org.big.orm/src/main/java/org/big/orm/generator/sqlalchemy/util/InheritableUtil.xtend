package org.big.orm.generator.sqlalchemy.util

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
import org.big.orm.generator.common.CommonUtil
import java.util.Map
import java.util.HashMap
import org.big.orm.ormModel.EnumAttribute

@Singleton
class InheritableUtil {
	
	@Inject extension ImportUtil importUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension RelationshipUtil relationshipUtil;
	@Inject extension CommonUtil commonUtil;
	Map<InheritableElement, List<CharSequence>> globalTableArgs = new HashMap<InheritableElement, List<CharSequence>>();
	Map<InheritableElement, List<CharSequence>> globalMapperArgs = new HashMap<InheritableElement, List<CharSequence>>();
	
	def reset(){
		globalTableArgs.clear;
		globalMapperArgs.clear;
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
		«IF (e instanceof Entity) && (e as Entity).inheritanceStrategy === InheritanceStrategy.SINGLE_TABLE && (e as Entity).rootElement !== e»
		__tablename__ = «(e as Entity).rootElement.name».__tablename__
		«ENDIF»
		«IF (e instanceof Entity) && (e as Entity).inheritanceStrategy === InheritanceStrategy.TABLE_PER_CLASS»
		«(e as Entity).compileTablePerClassInheritedAttributes»
		«ENDIF»
		«IF (e instanceof Entity) && (e as Entity).inheritanceStrategy === InheritanceStrategy.JOINED_TABLE»
		«(e as Entity).compileJoinedTableInheritedAttributes»
		«ENDIF»
		«FOR a : e.attributes.filter(DataAttribute)»
		«a.compileToSqlAlchemyAttribute(null)»
		«ENDFOR»
		«FOR a : e.attributes.filter(EnumAttribute)»
		«a.compileToSqlAlchemyAttribute(null)»
		«ENDFOR»
		«FOR a : e.attributes.filter(EmbeddedAttribute)»
		
		«a.compileToSqlAlchemyAttribute(null)»
		«ENDFOR»
		«IF (e instanceof Entity)»
		«e.compileEntityBody»
		«ENDIF»
	'''
	
	def CharSequence compileEntityBody(Entity e)
	'''
	«e.compileRelationships»
	«e.compileEntityInheritance»
	«IF (!e.mapperArgs.empty)»
	
	__mapper_args__ = {
		«FOR mapperArg : e.mapperArgs»
		«mapperArg»,
		«ENDFOR»
	}
	«ENDIF»
	«IF (!e.tableArgs.empty)»
	
	__table_args__ = (
		«FOR tableArg : e.tableArgs»
		«tableArg»,
		«ENDFOR»
	)
	«ENDIF»
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
	//  && (e.eContainer as OrmModel).elements.filter(Entity).filter[elem | elem.extends === e].empty
	private def CharSequence compileSingleTableInheritance (Entity e) {
		if (e.rootElement === e) {
			e.mapperArgs.add('''"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»"''')
			e.mapperArgs.add('''"polymorphic_on": dtype''')
			'''
			dtype: Mapped[str] = mapped_column(String(31), nullable=False)
			'''
		} else {
			e.mapperArgs.add('''"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»"''')
			e.tableArgs.add('''{'extend_existing': True}''')
			''''''
		}
	}
	
	private def CharSequence compileJoinedTableInheritedAttributes (Entity e) {
		if (e.rootElement !== e) {
			var Attribute keyAttribute = e.keyAttribute;
			'''
			«keyAttribute.compileToSqlAlchemyAttribute(e.rootElement)»
			'''
		} else {
			''''''
		}
	}
	
	private def CharSequence compileJoinedTableInheritance (Entity e) {
		if (e.rootElement !== e){
			var List<String> lowUnderKeyAttributeNames = e.keyAttributesAsDataAttributes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]
			var String lowUnderEntityName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)
			e.mapperArgs.add('''"polymorphic_identity": "«lowUnderEntityName»"''')
			e.mapperArgs.add('''"inherit_condition": «String.join(" and ", lowUnderKeyAttributeNames.map[name | "(" + name + " == " + e.rootElement.name + "." + name + ")"])»''')
			e.tableArgs.add('''ForeignKeyConstraint([«String.join(", ", lowUnderKeyAttributeNames)»], [«String.join(", ", lowUnderKeyAttributeNames.map[name | e.rootElement.name + "." + name])»], name="fk_«lowUnderEntityName»_id")''')
			''''''
		} else {
			''''''
		}
	}
	
	private def CharSequence compileTablePerClassInheritanceArgs (Entity e) {
		e.mapperArgs.add('''"polymorphic_identity": "«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.name)»"«(e.rootElement !== e) ? ''', "concrete": True'''»''')
		''''''
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
	
	
	private def List<CharSequence> combineInheritedAttributes(InheritableElement i)
	{
		val attributes = new ArrayList<CharSequence>()
		if (i.extends !== null) {
			attributes.addAll(i.extends.combineInheritedAttributes)
			attributes.add('''
			''')
		}
		
		for (attribute : i.attributes.filter(DataAttribute)) {
			attributes.add(attribute.compileToSqlAlchemyAttribute(null))
		}
		
		for (attribute : i.attributes.filter(EnumAttribute)) {
			attributes.add(attribute.compileToSqlAlchemyAttribute(null))
		}
		
		for (attribute : i.attributes.filter(EmbeddedAttribute)) {
			attributes.add(attribute.compileToSqlAlchemyAttribute(null))
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
	
	def List<CharSequence> getTableArgs(InheritableElement i) {
		var List<CharSequence> list = globalTableArgs.getOrDefault(i, new ArrayList<CharSequence>());
		globalTableArgs.putIfAbsent(i, list);
		return list
	}
	
	def List<CharSequence> getMapperArgs(InheritableElement i) {
		var List<CharSequence> list = globalMapperArgs.getOrDefault(i, new ArrayList<CharSequence>());
		globalMapperArgs.putIfAbsent(i, list);
		return list
	}
}