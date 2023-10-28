package org.big.orm.language.java

import org.big.orm.ormModel.OrmModel
import org.big.orm.language.javaModel.JavaModel
import java.util.List
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.language.javaModel.JavaElement
import java.util.ArrayList
import org.big.orm.language.javaModel.JavaClass
import org.big.orm.language.javaModel.Statement
import org.big.orm.ormModel.DataType
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.Embeddable
import org.big.orm.ormModel.EmbeddedAttribute
import com.google.common.collect.Iterables
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.RelationEntity
import org.big.orm.ormModel.MappedClass

class JavaModel2OrmModelConverter {
	
	var OrmModel model = null
	
	def OrmModel generateOrmModelFromJavaModels(String name, List<JavaModel> javaModels){
		
		model = OrmModelFactory.eINSTANCE.createOrmModel()
		
		model.name = name
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEmbeddablesFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateMappedClassesFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEntitiesFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.relationships.addAll(generateRelationshipsFromJavaModel(javaModel))
		]
		
		return model
	}
	
	def List<Embeddable> generateEmbeddablesFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val List<Embeddable> ret = new ArrayList<Embeddable>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[name.equals("Embeddable")].empty]
		
		classes.forEach[clazz | 
			var Embeddable embeddable = OrmModelFactory.eINSTANCE.createEmbeddable
			embeddable.name = clazz.name
			embeddable.attributes.addAll(generateDataAttributesFromClass(clazz))
			ret.add(embeddable)
		]
		
		classes.forEach[clazz |
			var Embeddable embeddable = ret.findFirst[name.equals(clazz.name)]
			embeddable.attributes.addAll(generateEmbeddedAttributesFromClass(clazz))
			ret.add(embeddable)
		]
		
		return ret
	}
	
	def List<MappedClass> generateMappedClassesFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val ret = new ArrayList<MappedClass>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[name.equals("MappedSuperclass")].empty]
		
		classes.forEach[clazz | 
			var MappedClass mappedClass = OrmModelFactory.eINSTANCE.createMappedClass
			mappedClass.name = clazz.name
			mappedClass.attributes.addAll(generateDataAttributesFromClass(clazz))
			ret.add(mappedClass)
		]
		
		return ret
	}
	
	def List<Entity> generateEntitiesFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val ret = new ArrayList<Entity>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[name.equals("Entity")].empty]
		
		classes.forEach[clazz | 
			var Entity ormEntity = OrmModelFactory.eINSTANCE.createEntity
			ormEntity.name = clazz.name
			ormEntity.attributes.addAll(generateDataAttributesFromClass(clazz))
			ormEntity.attributes.addAll(generateEmbeddedAttributesFromClass(clazz))
			ret.add(ormEntity)
		]
		
		return ret
	}
	
	
	def List<DataAttribute> generateDataAttributesFromClass(JavaClass javaClass){
		
		val ret = new ArrayList<DataAttribute>
		
		var elements = javaClass.elements.filter[element instanceof Statement]
		
		elements = elements.filter[annotations.filter[name.equals("ManyToOne") || name.equals("ManyToMany") || name.equals("OneToOne") || name.equals("OneToMany")].empty]
		elements = elements.filter[annotations.filter[name.equals("Embedded") || name.equals("EmbeddedId")].empty]
		
		
		elements.forEach[element | 
			var DataAttribute attribute = OrmModelFactory.eINSTANCE.createDataAttribute
			attribute.datatype = switch ((element.element as Statement).type){
				case "UUID": DataType.UUID
				case "Boolean": DataType.BOOLEAN
				case "Integer": DataType.INT
				default: DataType.STRING
			}
			if (!element.annotations.filter[name.equals("Id")].empty){
				attribute.type = AttributeType.ID
			}
			attribute.name = (element.element as Statement).name
			ret.add(attribute)
		]
		return ret
	}
	
	def List<EmbeddedAttribute> generateEmbeddedAttributesFromClass(JavaClass javaClass){
		
		val ret = new ArrayList<EmbeddedAttribute>
		
		var elements = javaClass.elements.filter[element instanceof Statement]
		
		elements = elements.filter[annotations.filter[name.equals("ManyToOne") || name.equals("ManyToMany") || name.equals("OneToOne") || name.equals("OneToMany")].empty]
		elements = elements.filter[!annotations.filter[name.equals("Embedded") || name.equals("EmbeddedId")].empty]
		
		
		elements.forEach[element | 
			var EmbeddedAttribute attribute = OrmModelFactory.eINSTANCE.createEmbeddedAttribute
			val embeddable = Iterables.getFirst(model.elements.filter(Embeddable).filter[name.equals((element.element as Statement).type)], null)
			if (embeddable !== null){
				attribute.embeddedType = embeddable
				if (!element.annotations.filter[name.equals("Id") || name.equals("EmbeddedId")].empty){
					attribute.type = AttributeType.ID
				}
				attribute.name = (element.element as Statement).name
				ret.add(attribute)
			}

		]
		return ret
	}
	
		
	def List<Relationship> generateRelationshipsFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val ret = new ArrayList<Relationship>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[name.equals("Entity") || name.equals("Embeddable")].empty]
		
		
		
		classes.forEach[clazz | 
			var relationships = clazz.elements.filter[element instanceof Statement]
			relationships = relationships.filter[!annotations.filter[name.equals("ManyToOne") || name.equals("ManyToMany") || name.equals("OneToOne") || name.equals("OneToMany")].empty]
			relationships = relationships.filter[!annotations.filter[name.equals("JoinColumn") || name.equals("JoinTable")].empty]
			relationships.forEach[relationship |
				var Relationship ormRelationship = OrmModelFactory.eINSTANCE.createRelationship
				ormRelationship.type =  switch (relationship.annotations){
					case !relationship.annotations.filter[name.equals("ManyToOne")].empty : RelationshipType.MANY_TO_ONE
					case !relationship.annotations.filter[name.equals("ManyToMany")].empty : RelationshipType.MANY_TO_MANY
					case !relationship.annotations.filter[name.equals("OneToOne")].empty : RelationshipType.ONE_TO_ONE
					case !relationship.annotations.filter[name.equals("OneToMany")].empty : RelationshipType.ONE_TO_MANY
				}
				ormRelationship.unidirectional = true
				
				var RelationEntity source = OrmModelFactory.eINSTANCE.createRelationEntity
				source.attributeName = (relationship.element as Statement).name
				val sourceEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals(clazz.name)], null)
				if (sourceEntity !== null) {
					source.entity = sourceEntity
					ormRelationship.source = source
					val targetEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals((relationship.element as Statement).type)], null)
					if (targetEntity !== null){
						var RelationEntity target = OrmModelFactory.eINSTANCE.createRelationEntity
						target.entity=targetEntity
						ormRelationship.target = target
						ormRelationship.name = sourceEntity.name+targetEntity.name
						ret.add(ormRelationship)
					}
				}
			]
		]
		
		return ret
	}
	
	
}