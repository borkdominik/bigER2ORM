package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import java.util.List
import org.big.orm.ormModel.Relationship
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.Entity
import com.google.inject.Inject
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.InheritanceStrategy
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.OrmModelFactory

@Singleton
class ModelUtil {
	
	@Inject extension CommonUtil commonUtil;
	
	def compileModelFile(List<Entity> entities, List<Relationship> relationships, String modelName){
	
	'''
	using «modelName».entity;
	using Microsoft.EntityFrameworkCore;
	using Microsoft.EntityFrameworkCore.Metadata.Conventions;
	
	public class «CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, modelName)»Context : DbContext
	{
		«FOR entity : entities.sortBy[name] SEPARATOR "\n"»public DbSet<«entity.name»> «entity.name» { get; set; }«ENDFOR»
		
		protected override void OnConfiguring(DbContextOptionsBuilder options)
			=> options
				.UseNpgsql("Host=localhost;Database=csharp;Username=postgres;Password=postgres")
				.UseSnakeCaseNamingConvention();
	
		protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
		{
			configurationBuilder.Conventions.Remove(typeof(ForeignKeyIndexConvention));
		}
		
		protected override void OnModelCreating(ModelBuilder modelBuilder)
		{
	
			// INHERTIANCE
			
			«FOR rootEntity : entities.filter[entity | entity === entity.rootElement]»
			«rootEntity.compileInheritance(entities.filter[entity | (entity.rootElement === rootEntity && entity !== rootEntity)].toList)»
			«ENDFOR»
			// END INHERITANCE
	
			// RELATIONSHIPS
			
			«FOR relationship :relationships»
			«relationship.compileRelationshipForModel»
			«ENDFOR»
			// END RELATIONSHIPS
		}
	}
	'''
	}
	
	
	def compileInheritance(Entity rootEntity, List<Entity> childEntities) {
		switch rootEntity.inheritanceStrategy {
			case InheritanceStrategy.JOINED_TABLE: rootEntity.compileJoinedTableInheritance(childEntities)
			case InheritanceStrategy.TABLE_PER_CLASS: rootEntity.compileTablePerClassInheritance
			case InheritanceStrategy.SINGLE_TABLE, case InheritanceStrategy.UNDEFINED: childEntities.empty ? '''''' : rootEntity.compileSingleTableInheritance(childEntities)
			default: ''''''
		}
	}
	
	def compileJoinedTableInheritance(Entity rootEntity, List<Entity> childEntities) {
		'''
		// Table-per-Type doesn't support renaming primary keys: https://github.com/dotnet/efcore/issues/19970
		modelBuilder.Entity<«rootEntity.name»>().UseTptMappingStrategy();
		
		«FOR childEntity: childEntities SEPARATOR "\n"»
		modelBuilder.Entity<«childEntity.name»>()
			.HasOne<«childEntity.extends.name»>()
			.WithOne()
			.HasForeignKey<«childEntity.name»>(e => new { «rootEntity.keyAttributesAsDataAttributes.joinKeys» })
			.HasPrincipalKey<«childEntity.extends.name»>(e => new { «rootEntity.keyAttributesAsDataAttributes.joinKeys» })
			.HasConstraintName("fk_«CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, childEntity.name)»_id")
			.OnDelete(DeleteBehavior.NoAction);
		«ENDFOR»
		
		'''
	}
	
	def compileTablePerClassInheritance(Entity rootEntity) {
		'''
		modelBuilder.Entity<«rootEntity.name»>().UseTpcMappingStrategy();
		
		'''
	}
	
	def compileSingleTableInheritance(Entity rootEntity, List<Entity> childEntities) {
		'''
		modelBuilder.Entity<«rootEntity.name»>()
			.HasDiscriminator<string>("dtype")
			.HasValue<Course>("Course")
			«FOR entity : childEntities SEPARATOR "\n"».HasValue<«entity.name»>("«entity.name»")«ENDFOR»;

		modelBuilder.Entity<«rootEntity.name»>()
			.Property("dtype")
			.HasMaxLength(31);
		
		'''
	}
	
	def compileRelationshipForModel(Relationship relationship) {
		switch relationship.type {
			case RelationshipType.ONE_TO_ONE, case RelationshipType.MANY_TO_ONE: relationship.compileXToOneRelationshipForModel
			case RelationshipType.MANY_TO_MANY: relationship.attributes.empty ? relationship.compileManyToManyUsingJoinTableRelationshipForModel : relationship.compileManyToManyUsingJoinEntityRelationshipForModel
			default: ''''''
		}
	}
	
	def compileXToOneRelationshipForModel(Relationship relationship) {
		val List<DataAttribute> keyAttributes = relationship.target.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(relationship.source.attributeName) as DataAttribute].toList;
		val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.source.entity.name);
		val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.source.attributeName);
		'''
		modelBuilder.Entity<«relationship.source.entity.name»>()
			.HasOne(e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.source.attributeName)»)
			.With«relationship.type === RelationshipType.ONE_TO_ONE ? "One" : "Many"»(«IF !relationship.unidirectional»e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.target.attributeName)»«ENDIF»)
			.HasForeignKey«IF relationship.type === RelationshipType.ONE_TO_ONE»<«relationship.source.entity.name»>«ENDIF»(e => new { «keyAttributes.joinKeys» })
			.HasConstraintName("fk_«lowUnderSourceTableName»_«lowUnderSourceAttributeName»")
			.OnDelete(DeleteBehavior.NoAction);
		
		'''
	}
	
	def compileManyToManyUsingJoinTableRelationshipForModel(Relationship relationship) {
		var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.name)
	
		val String lowUnderSourceTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.source.entity.name)
		val String lowUnderTargetTableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.target.entity.name)
		val String lowUnderSourceAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.source.attributeName)
		val String lowUnderTargetAttributeName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.target.attributeName)
	
		var List<String> lowUnderSourceIdNames = relationship.source.entity.keyAttributesAsDataAttributes.map[attribute | '''"«lowUnderSourceTableName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)»"''']
		var List<String> lowUnderTargetIdNames = relationship.target.entity.keyAttributesAsDataAttributes.map[attribute | '''"«lowUnderTargetTableName»_«CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, attribute.name)»"''']
		'''
		modelBuilder.Entity<«relationship.source.entity.name»>()
			.HasMany(e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.source.attributeName)»)
			.WithMany(e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.target.attributeName)»)
			.UsingEntity<Dictionary<string, object>>(
				"«tableName»",
				e => e
					.HasOne<«relationship.target.entity.name»>()
					.WithMany()
					.HasForeignKey([«lowUnderTargetIdNames.join(", ")»])
					.HasConstraintName("fk_«tableName»_«lowUnderTargetAttributeName»")
					.OnDelete(DeleteBehavior.NoAction),
				e => e
					.HasOne<«relationship.source.entity.name»>()
					.WithMany()
					.HasForeignKey([«lowUnderSourceIdNames.join(", ")»])
					.HasConstraintName("fk_«tableName»_«lowUnderSourceAttributeName»")
					.OnDelete(DeleteBehavior.NoAction)
			)
			.HasNoKey();
		
		'''
	}
	
	def compileManyToManyUsingJoinEntityRelationshipForModel(Relationship relationship) {
		var Entity joinEntity  = OrmModelFactory.eINSTANCE.createEntity()
		joinEntity.name = relationship.name
		var Relationship sourceRelationship = createJoinRelationship(joinEntity, relationship.source)
		var Relationship targetRelationship = createJoinRelationship(joinEntity, relationship.target)
		
		//var String lowUnderRelationshipName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, relationship.name)
		//val List<DataAttribute> sourceKeyAttributes = relationship.source.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, relationship.source.entity.name)) as DataAttribute].toList;
		//val List<DataAttribute> targetKeyAttributes = relationship.target.entity.keyAttributesAsDataAttributes.map[a | a.copyAttribute(CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_CAMEL, relationship.target.entity.name)) as DataAttribute].toList;
		'''
		«sourceRelationship.compileXToOneRelationshipForModel»
		«targetRelationship.compileXToOneRelationshipForModel»
		'''
		
//				modelBuilder.Entity<«relationship.name»>()
//			.HasMany(e => e.«relationship.source.entity.name»)
//			.WithOne(e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.source.attributeName)»)
//			.HasForeignKey(e => new { «sourceKeyAttributes.joinKeys» })
//			.HasConstraintName("fk_«lowUnderRelationshipName»_student_card")
//			.OnDelete(DeleteBehavior.NoAction);
//
//		modelBuilder.Entity<«relationship.name»>()
//			.HasMany(e => e.«relationship.target.entity.name»)
//			.WithOne(e => e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, relationship.target.attributeName)»)
//			.HasForeignKey(e => new { «targetKeyAttributes.joinKeys» })
//			.HasConstraintName("fk_«lowUnderRelationshipName»_study_program")
//			.OnDelete(DeleteBehavior.NoAction);
		
	}
	
	private def joinKeys(List<DataAttribute> keys){
		keys.map[key | '''e.«CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, key.name)»'''].join(", ")	
	}
}