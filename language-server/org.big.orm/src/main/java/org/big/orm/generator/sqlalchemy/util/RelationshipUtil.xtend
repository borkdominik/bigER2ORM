package org.big.orm.generator.sqlalchemy.util

import com.google.common.base.CaseFormat
import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.ArrayList
import java.util.List
import java.util.Map
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import org.eclipse.emf.ecore.resource.Resource
import org.big.orm.ormModel.RelationEntity

@Singleton
class RelationshipUtil {
	
		
	Resource resource
	
	@Inject extension ImportUtil importUtil;
	@Inject extension AttributeUtil attributeUtil;
	
	def setResource(Resource resource){
		this.resource = resource
	}
		
	
	def CharSequence compileAdditionTablesForManyToMany(Relationship r)
	'''
	«FOR i : r.generateImports»
	«i»
	«ENDFOR»
	
	
	«IF (r.attributes.empty)»
	«compileManyToManyTableWithoutAttributes(r)»
	«ELSE»
	«compileManyToManyJoinEntity(r)»
	«ENDIF»
	'''
	
	private def CharSequence compileManyToManyTableWithoutAttributes(Relationship r) {
	var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
	
	var String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name)
	var String lowUnderTargetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name)
	
	var String lowUnderSourceIdName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.keyAttributesAsDataAttributes.head.name)
	var String lowUnderTargetIdName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.keyAttributesAsDataAttributes.head.name)
	
	'''
	«tableName» = Table(
		"«tableName»",
		Base.metadata,
		Column("«lowUnderSourceTableName»_«lowUnderSourceIdName»", ForeignKey("«lowUnderSourceTableName».«lowUnderSourceIdName»", name="fk_«tableName»_«lowUnderSourceTableName»_«lowUnderSourceIdName»"), nullable=False),
		Column("«lowUnderTargetTableName»_«lowUnderTargetIdName»", ForeignKey("«lowUnderTargetTableName».«lowUnderTargetIdName»", name="fk_«tableName»_«lowUnderTargetTableName»_«lowUnderTargetIdName»"), nullable=False)
	)
	'''
	}
	
	private def CharSequence compileManyToManyJoinEntity(Relationship r) {
	var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
	var Entity joinEntity  = OrmModelFactory.eINSTANCE.createEntity()
	joinEntity.name = r.name
	var Relationship sourceRelationship = createJoinRelationship(joinEntity, r.source)
	var Relationship targetRelationship = createJoinRelationship(joinEntity, r.target)
	
	var List<String> keyAttributes = new ArrayList<String>();
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name);
	val String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name);
	keyAttributes.addAll(r.source.entity.keyAttributesAsDataAttributes.map[keyAttribute | "\"" + lowUnderSourceAttributeName + "_" + CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name) + "\""])
	keyAttributes.addAll(r.target.entity.keyAttributesAsDataAttributes.map[keyAttribute | "\"" + lowUnderTargetAttributeName + "_" + CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name) + "\""])
	
	'''
	class «r.name»(Base):
		__tablename__ = "«tableName»"
		«compileManyToOneForSource(sourceRelationship)»
		«compileManyToOneForSource(targetRelationship)»
		
		«FOR a : r.attributes.filter(DataAttribute)»
		«a.compileToSqlAlchemyAttribute»
		«ENDFOR»
		«FOR a : r.attributes.filter(EmbeddedAttribute)»
		«a.compileToSqlAlchemyAttribute»
		«ENDFOR»
		
		__table_args__ = (
			PrimaryKeyConstraint(«String.join(", ", keyAttributes)»),
		)
		'''
	}
	
	private def Relationship createJoinRelationship(Entity joinEntity, RelationEntity relationEntity) {
		var Relationship relationship = OrmModelFactory.eINSTANCE.createRelationship()
		relationship.source = OrmModelFactory.eINSTANCE.createRelationEntity()
		relationship.target = OrmModelFactory.eINSTANCE.createRelationEntity()
		relationship.sourceRequired = true
		relationship.source.entity = joinEntity
		relationship.source.attributeName = relationEntity.entity.name
		relationship.target.entity = relationEntity.entity
		relationship.target.attributeName = relationEntity.attributeName
		relationship.unidirectional = false
		return relationship
	}
		
	
	def CharSequence compileRelationships(Entity e)
	'''
	«FOR r : resource.allContents.toIterable.filter(Relationship).filter[source.entity === e]»
	«compileRelationshipForSource(r)»
	«ENDFOR»
	«FOR r : resource.allContents.toIterable.filter(Relationship).filter[target.entity === e && !unidirectional]»
	«compileRelationshipForTarget(r)»
	«ENDFOR»
	'''
	
	private def CharSequence compileRelationshipForSource(Relationship r){
		switch r.type {
			case RelationshipType.MANY_TO_MANY: r.attributes.empty ? compileManyToManyForSourceWithJoinTable(r) : compileManyToManyForSourceWithJoinEntity(r)
			case RelationshipType.MANY_TO_ONE: compileManyToOneForSource(r)
			case RelationshipType.ONE_TO_ONE: compileOneToOneForSource(r)
			default: ''''''
		}
	}
	
	private def CharSequence compileManyToManyForSourceWithJoinTable(Relationship r) {
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);
	var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
	'''
	«lowUnderSourceAttributeName»: Mapped[list["«r.target.entity.name»"]] = relationship("«r.target.entity.name»", secondary=«tableName»,
	                                         back_populates="«lowUnderTargetAttributeName»")
	'''
	}
	
	private def CharSequence compileManyToManyForSourceWithJoinEntity(Relationship r){
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	val String backPopulates = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name)
	'''
	«lowUnderSourceAttributeName»: Mapped[list["«r.name»"]] = relationship(back_populates="«backPopulates»")
	'''
	}
	
	private def CharSequence compileManyToOneForSource(Relationship r) {
	val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name);
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = ""
	if (!r.unidirectional) {
		lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);	
	}
	var List<Map.Entry<DataAttribute, String>> keyAttributesWithFK = new ArrayList<Map.Entry<DataAttribute, String>>()
	for (keyAttribute : r.target.entity.getKeyAttributesAsDataAttributes()){
		keyAttributesWithFK.add(
			Map.entry(
				keyAttribute, 
				"\"fk_" + lowUnderSourceTableName + "_" + lowUnderSourceAttributeName + "_" + CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name) + "\""
			)
		)
	}
	
	var String targetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name)
	val String foreignKeysListJoined = String.join(", ", keyAttributesWithFK.map[attributeEntry | lowUnderSourceAttributeName + "_" + CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attributeEntry.key.name)].toList)
	
	'''
	
	«FOR keyAttributeWithFK : keyAttributesWithFK»
	«lowUnderSourceAttributeName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttributeWithFK.key.name)»: Mapped[«keyAttributeWithFK.key.typeString»] = mapped_column(UUID(as_uuid=True),
	                                         ForeignKey("«targetTableName».«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttributeWithFK.key.name)»", name=«keyAttributeWithFK.value»)«IF r.sourceRequired»)«ELSE»,
	                                         nullable=True)«ENDIF»
	«ENDFOR»
	«lowUnderSourceAttributeName»: Mapped["«r.target.entity.name»"] = relationship(foreign_keys=[«foreignKeysListJoined»]«IF !r.unidirectional», back_populates="«lowUnderTargetAttributeName»"«ENDIF»)
	'''	
	}
	
	
	private def CharSequence compileOneToOneForSource(Relationship r)
	'''
	# One to X for source is not implemented yet
	'''
	
	private def CharSequence compileRelationshipForTarget(Relationship r){
		switch r.type {
			case RelationshipType.MANY_TO_MANY: r.attributes.empty ? compileManyToManyForTargetWithJoinTable(r) : compileManyToManyForTargetWithJoinEntity(r)
			case RelationshipType.MANY_TO_ONE: compileManyToOneForTarget(r)
			case RelationshipType.ONE_TO_ONE: compileOneToOneForTarget(r)
			default: ''''''
		}
	}

	private def CharSequence compileManyToOneForTarget(Relationship r) {
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);
	'''
	«lowUnderTargetAttributeName»: Mapped[list["«r.source.entity.name»"]] = relationship(back_populates="«lowUnderSourceAttributeName»")
	'''
	}
	
	private def CharSequence compileOneToOneForTarget(Relationship r) {
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);
	'''
	«lowUnderTargetAttributeName»: Mapped["«r.source.entity.name»"] = relationship(back_populates="«lowUnderSourceAttributeName»")
	'''
	}
	
	private def CharSequence compileManyToManyForTargetWithJoinTable(Relationship r) {
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);
	var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
	'''
	«lowUnderTargetAttributeName»: Mapped[list["«r.source.entity.name»"]] = relationship("«r.source.entity.name»", secondary=«tableName»,
	                                         back_populates="«lowUnderSourceAttributeName»")
	'''
	}
	
	private def CharSequence compileManyToManyForTargetWithJoinEntity(Relationship r){
	val String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);
	val String backPopulates = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name)
	'''
	«lowUnderTargetAttributeName»: Mapped[list["«r.name»"]] = relationship(back_populates="«backPopulates»")
	'''
	}
	
}