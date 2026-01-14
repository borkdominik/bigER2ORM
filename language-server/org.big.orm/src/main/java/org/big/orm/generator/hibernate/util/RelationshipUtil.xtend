package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.DataAttribute
import com.google.inject.Inject
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.OrmModel
import java.util.List
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.ormModel.Embeddable
import org.big.orm.ormModel.Attribute

@Singleton
class RelationshipUtil {
	
	@Inject extension InheritableUtil inheritableUtil;
	@Inject extension CommonUtil commonUtil;
	
	def CharSequence compileRelationships(Entity e) {
		val Iterable<Relationship> sourceRelationships = (e.eContainer as OrmModel).relationships.filter[relation | relation.source.entity.name.equals(e.name)]
		val Iterable<Relationship> targetRelationships = (e.eContainer as OrmModel).relationships.filter[relation | relation.target.entity.name.equals(e.name) && !relation.unidirectional]
    	'''
    	«FOR r : sourceRelationships SEPARATOR "\n"»
    	«r.compileRelationshipForSource»
    	«ENDFOR»«IF !sourceRelationships.empty»
    	
    	«ENDIF»
    	«FOR r : targetRelationships SEPARATOR "\n"»
    	«r.compileRelationshipForTarget»
    	«ENDFOR»«IF !targetRelationships.empty»
    	
    	«ENDIF»
    	'''
	}
	
	def compileRelationshipForSource(Relationship r) {
		switch r.type {
			case RelationshipType.MANY_TO_MANY: compileManyToManyForSource(r)
			case RelationshipType.MANY_TO_ONE: compileManyToOneForSource(r)
			case RelationshipType.ONE_TO_ONE: compileOneToOneForSource(r)
			default: ''''''
		}
	}
	
	def compileManyToOneForSource(Relationship r) {
		val Boolean isJoinEntity = (r.source.entity instanceof Entity) && (r.source.entity as Entity).joinEntity
		'''
		«IF isJoinEntity»@MapsId("«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, r.target.entity.name)»Id")
		«ENDIF»@ManyToOne«IF r.sourceRequired»(optional = false)«ENDIF»
		«compileJoinColumns(r)»
		private «r.target.entity.name» «r.source.attributeName»;
		'''
	}
	
	def compileManyToManyForSource(Relationship r){
		var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
		val List<DataAttribute> sourceKeyAttibutes = r.source.entity.keyAttributesAsDataAttributes
		val List<DataAttribute> targetKeyAttibutes = r.target.entity.keyAttributesAsDataAttributes
	
		val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name)
		val String lowUnderTargetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name)
		val String lowUnderSourceAttributeName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName)
		val String lowUnderTargetAttributeName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName)
		'''
		@ManyToMany
		@JoinTable(
		    name = "«tableName»",
		    joinColumns = {
		        «FOR keyAttribute : sourceKeyAttibutes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]»
		        @JoinColumn(name = "«lowUnderSourceTableName»_«keyAttribute»", referencedColumnName = "«keyAttribute»"),
		        «ENDFOR»
		    },
		    foreignKey = @ForeignKey(name = "fk_«tableName»_«lowUnderSourceAttributeName»"),
		    inverseJoinColumns = {
		        «FOR keyAttribute : targetKeyAttibutes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]»
		        @JoinColumn(name = "«lowUnderTargetTableName»_«keyAttribute»", referencedColumnName = "«keyAttribute»"),
		        «ENDFOR»
		    },
		    inverseForeignKey = @ForeignKey(name = "fk_«tableName»_«lowUnderTargetAttributeName»")
		)
		private List<«r.target.entity.name»> «r.source.attributeName»;
    	'''
    }
	
	def compileManyToManyForSourceWithJoinEntity(Relationship r)
	'''
	@OneToMany(mappedBy = "«r.source.entity.name.toFirstLower»")
	private List<«r.name»> «r.source.attributeName»;
    '''
	
	def compileOneToOneForSource(Relationship r)
	'''
	// Unique constraint name can't be set: https://hibernate.atlassian.net/browse/HHH-19006
	// Once finished refactor creation to be equivalent
	@OneToOne
	«r.compileJoinColumns»
	private StudentCard studentCard;
	'''
	
	private def compileJoinColumns(Relationship r) {
		val List<DataAttribute> keyAttibutes = r.target.entity.keyAttributesAsDataAttributes
		val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name);
		val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
		'''
		@JoinColumns(value = {
			«FOR keyAttribute : keyAttibutes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]»
			@JoinColumn(name = "«lowUnderSourceAttributeName»_«keyAttribute»", referencedColumnName = "«keyAttribute»"),
			«ENDFOR»
		}, foreignKey = @ForeignKey(name = "fk_«lowUnderSourceTableName»_«lowUnderSourceAttributeName»"))
		'''
	}
	
	
	def compileRelationshipForTarget(Relationship r){
		switch r.type {
			case RelationshipType.MANY_TO_MANY: compileManyToManyForTarget(r)
			case RelationshipType.MANY_TO_ONE: compileManyToOneForTarget(r)
			case RelationshipType.ONE_TO_ONE: compileOneToOneForTarget(r)
			default: ''''''
		}	
	}	
	
	def compileManyToOneForTarget(Relationship r)
	'''
	@OneToMany(mappedBy = "«r.source.attributeName»")
	private List<«r.source.entity.name»> «r.target.attributeName»;
	'''
	
	def compileManyToManyForTarget(Relationship r)
	'''
	@ManyToMany(mappedBy = "«r.source.attributeName»")
	private List<«r.source.entity.name»> «r.target.attributeName»;
    '''
	
	def compileOneToOneForTarget(Relationship r)
	'''
	@OneToOne(mappedBy = "«r.source.attributeName»")
	private «r.source.entity.name» «r.target.attributeName»;
	'''

	def compileJoinId(Entity e){
		var Embeddable joinEntityId  = OrmModelFactory.eINSTANCE.createEmbeddable()
		joinEntityId.name = e.name + "Id"
		(e.eContainer as OrmModel).elements.add(joinEntityId)
		
		var Attribute sourceKeyAttribute = e.joinSource.entity.keyAttribute.copyAttribute("")
		var Attribute targetKeyAttribute = e.joinTarget.entity.keyAttribute.copyAttribute("")

		sourceKeyAttribute.name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, e.joinSource.entity.name) + CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, sourceKeyAttribute.name)
		targetKeyAttribute.name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, e.joinTarget.entity.name) + CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, targetKeyAttribute.name)

		joinEntityId.attributes.add(sourceKeyAttribute);
		joinEntityId.attributes.add(targetKeyAttribute); 
		
		return joinEntityId.compile;
	}
}