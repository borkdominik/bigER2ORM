package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.ModelElement
import java.util.TreeSet
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.InheritanceOption
import org.big.orm.ormModel.InheritanceStrategy
import org.big.orm.ormModel.Embeddable
import org.big.orm.ormModel.MappedClass
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.DataType
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.EmbeddedAttribute
import java.util.ArrayList
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.OrmModel
import org.big.orm.ormModel.RelationshipType

@Singleton
class ImportUtil {
	
	def generateImports(ModelElement e) {
		val imports = new TreeSet<String>();
		
		if(e instanceof Entity){	
			imports.add("jakarta.persistence.Entity");
			
			// INHERITANCE
			if (!e.options.filter(InheritanceOption).empty) {
				imports.add("jakarta.persistence.Inheritance");	
				imports.add("jakarta.persistence.InheritanceType")
			}
			
			// INHERITANCE ON JOINED STRATEGY
			if (e.extends !== null && e.extends instanceof Entity) {
				if (!(e.extends as Entity).options.filter(InheritanceOption).filter[option == InheritanceStrategy.JOINED_TABLE].empty) {
					imports.add("jakarta.persistence.ForeignKey");
					imports.add("jakarta.persistence.PrimaryKeyJoinColumns")
				}
			}
			
		} else if (e instanceof Embeddable) {
			imports.add("jakarta.persistence.Embeddable");
			imports.add("java.io.Serializable");
		} else if (e instanceof MappedClass) {
			imports.add("jakarta.persistence.MappedSuperclass");
		}
		
		imports.add("lombok.Getter");
		imports.add("lombok.Setter");
		
		if(!e.attributes.filter(DataAttribute).empty){
			imports.add("jakarta.persistence.Column");
		}
		
		if(!e.attributes.filter(DataAttribute).filter[datatype.equals(DataType.UUID)].empty){
			imports.add("java.util.UUID");
		}
		
		if(!e.attributes.filter(DataAttribute).filter[type.equals(AttributeType.ID)].empty){
			imports.add("jakarta.persistence.Id");
			imports.add("jakarta.persistence.GenerationType");
			imports.add("jakarta.persistence.GeneratedValue");
		}
		
		if(!e.attributes.filter(DataAttribute).filter[type.equals(AttributeType.REQUIRED)].empty){
			imports.add("jakarta.persistence.Column");
		}
		
		if(!e.attributes.filter(EmbeddedAttribute).filter[type.equals(AttributeType.ID)].empty){
			imports.add("jakarta.persistence.EmbeddedId");
		}
		
		if(!e.attributes.filter(EmbeddedAttribute).filter[!type.equals(AttributeType.ID)].empty){
			imports.add("jakarta.persistence.Embedded");
		}
		
		
		
		// PREPARE RELATIONS
		
		
		val elementSourceRelations = new ArrayList<Relationship>();
		val elementTargetRelations = new ArrayList<Relationship>();
		
		for(r : (e.eContainer as OrmModel).relationships){
			if (r.source.entity === e) {
				elementSourceRelations.add(r)
			}
			if (r.target.entity === e && !r.unidirectional){
				elementTargetRelations.add(r)
			}
		}
		
		//SOURCE
		
		if(!elementSourceRelations.filter[type.equals(RelationshipType.MANY_TO_ONE)].empty){
			imports.add("jakarta.persistence.ManyToOne");
			imports.add("jakarta.persistence.JoinColumn");
			imports.add("jakarta.persistence.JoinColumns");
			imports.add("jakarta.persistence.ForeignKey");
		}
		
		if(!elementSourceRelations.filter[type.equals(RelationshipType.ONE_TO_ONE)].empty){
			imports.add("jakarta.persistence.OneToOne");
			imports.add("jakarta.persistence.JoinColumn");
			imports.add("jakarta.persistence.JoinColumns");
			imports.add("jakarta.persistence.ForeignKey");
		}
		
		//MANY-TO-MANY directly defined
		if(!elementSourceRelations.filter[type.equals(RelationshipType.MANY_TO_MANY)].filter[attributes.empty].empty){
			imports.add("jakarta.persistence.ManyToMany");
			imports.add("jakarta.persistence.JoinTable");
			imports.add("jakarta.persistence.JoinColumn");
			imports.add("jakarta.persistence.JoinColumns");
			imports.add("jakarta.persistence.ForeignKey");
			imports.add("java.util.List");
		}
		
		//MANY-TO-MANY using join entity
		if(!elementSourceRelations.filter[type.equals(RelationshipType.MANY_TO_MANY)].filter[!attributes.empty].empty){
			imports.add("jakarta.persistence.OneToMany");
			imports.add("java.util.List");
		}
		
		//TARGET
		
		if(!elementTargetRelations.filter[type.equals(RelationshipType.MANY_TO_ONE)].empty){
			imports.add("jakarta.persistence.OneToMany");		
			imports.add("java.util.List");
		}
		
		if(!elementTargetRelations.filter[type.equals(RelationshipType.ONE_TO_ONE)].empty){
			imports.add("jakarta.persistence.OneToOne");
		}
		
		//MANY-TO-MANY directly defined
		if(!elementTargetRelations.filter[type.equals(RelationshipType.MANY_TO_MANY)].filter[attributes.empty].empty){
			imports.add("jakarta.persistence.ManyToMany");		
			imports.add("java.util.List");
		}
		//MANY-TO-MANY using join entity
		if(!elementTargetRelations.filter[type.equals(RelationshipType.MANY_TO_MANY)].filter[!attributes.empty].empty){
			imports.add("jakarta.persistence.OneToMany");
			imports.add("java.util.List");
		}
		
		return imports;
	}
}