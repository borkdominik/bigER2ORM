package org.big.orm.generator.sqlalchemy.util

import com.google.common.base.CaseFormat
import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.ArrayList
import java.util.List
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.OrmModel
import org.big.orm.generator.common.CommonUtil

@Singleton
class RelationshipUtil {
	
	@Inject extension ImportUtil importUtil;
	@Inject extension AttributeUtil attributeUtil;
	@Inject extension CommonUtil commonUtil;
	@Inject extension InheritableUtil inheritableUtil;
		
		
	def CharSequence compileRelationships(Entity e)
	'''
	«FOR r : (e.eContainer as OrmModel).relationships.filter[source.entity === e]»
	«compileRelationshipForSource(r)»
	«ENDFOR»
	«FOR r : (e.eContainer as OrmModel).relationships.filter[target.entity === e && !unidirectional]»
	«compileRelationshipForTarget(r)»
	«ENDFOR»
	'''
	
	
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
	
	val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name)
	val String lowUnderTargetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name)
	val String lowUnderSourceAttributeName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName)
	val String lowUnderTargetAttributeName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName)
	
	var List<String> lowUnderSourceIdNames = r.source.entity.keyAttributesAsDataAttributes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]
	var List<String> lowUnderTargetIdNames = r.target.entity.keyAttributesAsDataAttributes.map[attribute | CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)]
	
	'''
	«tableName» = Table(
		"«tableName»",
		Base.metadata,
		«FOR attributeName : lowUnderSourceIdNames»
		Column("«lowUnderSourceTableName»_«attributeName»", nullable=False),
		«ENDFOR»
		«FOR attributeName : lowUnderTargetIdNames»
		Column("«lowUnderTargetTableName»_«attributeName»", nullable=False),
		«ENDFOR»
		ForeignKeyConstraint([«String.join(", ", lowUnderSourceIdNames.map[attributeName | '''"«lowUnderSourceTableName»_«attributeName»"'''])»], [«String.join(", ", lowUnderSourceIdNames.map[attributeName | '''"«lowUnderSourceTableName».«attributeName»"'''])»], name="fk_«tableName»_«lowUnderSourceAttributeName»"),
		ForeignKeyConstraint([«String.join(", ", lowUnderTargetIdNames.map[attributeName | '''"«lowUnderTargetTableName»_«attributeName»"'''])»], [«String.join(", ", lowUnderTargetIdNames.map[attributeName | '''"«lowUnderTargetTableName».«attributeName»"'''])»], name="fk_«tableName»_«lowUnderTargetAttributeName»")
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
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, sourceRelationship.source.attributeName);
	val String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetRelationship.source.attributeName);
	
	// NOTE: To match ordering of Hibernate, need to sort based on keyAttribute name
	val List<String> dataKeys = new ArrayList<String>()
	val List<String> embeddedKeys = new ArrayList<String>()
	
	val List<DataAttribute> sourceKeys = r.source.entity.keyAttributesAsDataAttributes;
	val List<DataAttribute> targetKeys = r.target.entity.keyAttributesAsDataAttributes;
	
	(sourceKeys.length > 1 ? embeddedKeys : dataKeys).addAll(sourceKeys.map[keyAttribute | '''"«lowUnderSourceAttributeName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»"''']);
	(targetKeys.length > 1 ? embeddedKeys : dataKeys).addAll(targetKeys.map[keyAttribute | '''"«lowUnderTargetAttributeName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»"''']);
	
	keyAttributes.addAll(dataKeys.sort)
	keyAttributes.addAll(embeddedKeys.sort)
	
	joinEntity.tableArgs.add('''PrimaryKeyConstraint(«String.join(", ", keyAttributes)»)''')
	
	'''
	class «r.name»(Base):
		__tablename__ = "«tableName»"
		«compileXToOneForSource(sourceRelationship)»
		«compileXToOneForSource(targetRelationship)»
		
		«FOR a : r.attributes.filter(DataAttribute)»
		«a.compileToSqlAlchemyAttribute(null)»
		«ENDFOR»
		«FOR a : r.attributes.filter(EmbeddedAttribute)»
		«a.compileToSqlAlchemyAttribute(null)»
		«ENDFOR»
		
		__table_args__ = (
			«FOR tableArg : joinEntity.tableArgs»
			«tableArg»,
			«ENDFOR»
		)
	'''
	}
	
	private def CharSequence compileRelationshipForSource(Relationship r){
		switch r.type {
			case RelationshipType.MANY_TO_MANY: r.attributes.empty ? compileManyToManyForSourceWithJoinTable(r) : compileManyToManyForSourceWithJoinEntity(r)
			case RelationshipType.MANY_TO_ONE: compileXToOneForSource(r)
			case RelationshipType.ONE_TO_ONE: compileXToOneForSource(r)
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
	
	private def CharSequence compileXToOneForSource(Relationship r) {
	val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.entity.name);
	val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.source.attributeName);
	var String lowUnderTargetAttributeName = ""
	if (!r.unidirectional) {
		lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.attributeName);	
	}
	val String lowUnderTargetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.target.entity.name);
	var List<DataAttribute> keyAttributes = r.target.entity.keyAttributesAsDataAttributes
	var String sourceIdAttributes = String.join(", ", keyAttributes.map[keyAttribute | '''«lowUnderSourceAttributeName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»'''])
	var String targetIdAttributes = String.join(", ", keyAttributes.map[keyAttribute | '''"«lowUnderTargetTableName».«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»"'''])
	r.source.entity.tableArgs.add('''ForeignKeyConstraint([«sourceIdAttributes»], [«targetIdAttributes»], name="fk_«lowUnderSourceTableName»_«lowUnderSourceAttributeName»")''')
	
	if (r.type === RelationshipType.ONE_TO_ONE) {
		val String attributeNames = String.join(", ", keyAttributes.map[keyAttribute | '''«lowUnderTargetTableName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»'''])
		val String uniqueConstraintName = '''«lowUnderSourceTableName»_«String.join("_", keyAttributes.map[keyAttribute | '''«lowUnderTargetTableName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»'''])»_key'''
		r.source.entity.tableArgs.add('''UniqueConstraint(«attributeNames», name="«uniqueConstraintName»")''')
	}
	'''
	
	«FOR keyAttribute : keyAttributes»
	«lowUnderSourceAttributeName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, keyAttribute.name)»: Mapped[«keyAttribute.typeString»] = mapped_column(«keyAttribute.mappedTypeString»«IF r.sourceRequired»)«ELSE», nullable=True)«ENDIF»
	«ENDFOR»
	«lowUnderSourceAttributeName»: Mapped["«r.target.entity.name»"] = relationship(foreign_keys=[«sourceIdAttributes»]«IF !r.unidirectional», back_populates="«lowUnderTargetAttributeName»"«ENDIF»)
	'''	
	}
	
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