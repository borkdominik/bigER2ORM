package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.OrmModel
import com.google.inject.Inject
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.DataAttribute
import com.google.common.base.CaseFormat
import java.util.List
import org.big.orm.ormModel.OrmModelFactory

@Singleton
class RelationshipUtil {
	
	@Inject extension CommonUtil commonUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension InheritableUtil inheritableUtil;
	
	def CharSequence compileRelationshipAttributes(Entity e) {
		val Iterable<Relationship> sourceRelationships = (e.eContainer as OrmModel).relationships.filter[relation | relation.source.entity.name.equals(e.name)]
		val Iterable<Relationship> targetRelationships = (e.eContainer as OrmModel).relationships.filter[relation | relation.target.entity.name.equals(e.name) && !relation.unidirectional]
    	'''
    	«FOR r : sourceRelationships SEPARATOR "\n"»
    	«r.compileRelationshipAttributesForSource»
    	«ENDFOR»«IF !sourceRelationships.empty»
    	
    	«ENDIF»
    	«FOR r : targetRelationships SEPARATOR "\n"»
    	«r.compileRelationshipAttributesForTarget»
    	«ENDFOR»«IF !targetRelationships.empty»
    	
    	«ENDIF»
    	'''
	}
	
	def compileRelationshipAttributesForSource(Relationship r) {
		switch r.type {
			case RelationshipType.MANY_TO_MANY: r.attributes.empty ? compileManyToManyAttributesForSourceWithJoinTable(r) : compileManyToManyAttributesForSourceWithJoinEntity(r)
			case RelationshipType.MANY_TO_ONE, case RelationshipType.ONE_TO_ONE: compileXToOneAttributesForSource(r)
			default: ''''''
		}
	}
	
	def compileXToOneAttributesForSource(Relationship r) {
	val Iterable<DataAttribute> keyAttributes = r.target.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(r.source.attributeName) as DataAttribute];
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.source.attributeName)
	'''
	«FOR keyAttribute : keyAttributes»«keyAttribute.compileToEntityFrameworkAttribute(r.sourceRequired)»«ENDFOR»
	public «IF r.sourceRequired»required «r.target.entity.name»«ELSE»«r.target.entity.name»?«ENDIF» «upperCamelAttributeName» { get; set; }
	'''	
	}
	
	
	def compileManyToManyAttributesForSourceWithJoinTable(Relationship r){
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.source.attributeName)
	'''
	public List<«r.target.entity.name»>? «upperCamelAttributeName» { get; set; }
	'''	
	}
	
	def compileManyToManyAttributesForSourceWithJoinEntity(Relationship r){
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.source.attributeName)
	'''
	public List<«r.name»>? «upperCamelAttributeName» { get; set; }
	'''	
	}
	
	def compileRelationshipAttributesForTarget(Relationship r){
		switch r.type {
			case RelationshipType.MANY_TO_MANY: r.attributes.empty ? compileManyToXAttributesForTargetWithoutJoinEntity(r) : compileManyToManyAttributesForTargetWithJoinEntity(r)
			case RelationshipType.MANY_TO_ONE: compileManyToXAttributesForTargetWithoutJoinEntity(r)
			case RelationshipType.ONE_TO_ONE: compileOneToOneAttributesForTarget(r)
			default: ''''''
		}	
	}	
	
	def compileManyToXAttributesForTargetWithoutJoinEntity(Relationship r) {
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.target.attributeName)
	'''
	public List<«r.source.entity.name»>? «upperCamelAttributeName» { get; set; }
	'''
	}
	
	
	def compileManyToManyAttributesForTargetWithJoinEntity(Relationship r){
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.target.attributeName)
	'''
	public List<«r.name»>? «upperCamelAttributeName» { get; set; }
	'''	
	}
	
	def compileOneToOneAttributesForTarget(Relationship r){
	val String upperCamelAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, r.target.attributeName)
	'''
	public «r.source.entity.name»? «upperCamelAttributeName» { get; set; }
	'''
	}
	
	def compileJoinEntity(Relationship r) {
	val List<DataAttribute> keyAttributes = (r.source.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(r.source.entity.name) as DataAttribute] + r.target.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(r.target.entity.name) as DataAttribute]).toList
	var Entity joinEntity  = OrmModelFactory.eINSTANCE.createEntity()
	joinEntity.name = r.name
	var Relationship sourceRelationship = createJoinRelationship(joinEntity, r.source)
	var Relationship targetRelationship = createJoinRelationship(joinEntity, r.target)
	'''
	using Microsoft.EntityFrameworkCore;
	using System.ComponentModel.DataAnnotations.Schema;
	
	namespace «inheritableUtil.modelName».entity
	{
	    [Table("«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)»")]
	    [PrimaryKey(«keyAttributes.map[attribute | '''nameof(«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, attribute.name)»)'''].join(", ")»)]
	    public class «r.name»
	    {
	    	«sourceRelationship.compileRelationshipAttributesForSource»
	
	    	«targetRelationship.compileRelationshipAttributesForSource»
	
	    	«FOR attribute : r.attributes.allAttributesAsDataAttributes SEPARATOR "\n"»
	    	«attribute.compileToEntityFrameworkAttribute(false)»
	    	«ENDFOR»
	    }
	}
	'''
	}
}