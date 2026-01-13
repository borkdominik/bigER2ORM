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
import org.big.orm.ormModel.OrmEnum
import org.big.orm.language.javaModel.JavaEnum
import org.big.orm.ormModel.EnumValue
import org.big.orm.ormModel.Attribute
import org.big.orm.ormModel.EnumAttribute
import org.big.orm.ormModel.InheritableElement
import org.big.orm.ormModel.InheritanceStrategy

class JavaModel2OrmModelConverter {
	
	var OrmModel model = null
	var List<JavaClass> joinClasses = null
	var List<JavaClass> joinClassEmbeddedIds = null
	
	def OrmModel generateOrmModelFromJavaModels(String name, List<JavaModel> javaModels){
		
		model = OrmModelFactory.eINSTANCE.createOrmModel()
		
		model.name = name
		joinClasses = new ArrayList<JavaClass>
		joinClassEmbeddedIds = new ArrayList<JavaClass>
		
		setJoinClassesAndEmbeddables(javaModels)
		
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEmbeddablesFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEnumsFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateMappedClassesFromJavaModel(javaModel))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEntitiesFromJavaModel(javaModel, true))
		]
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateEntitiesFromJavaModel(javaModel, false))
		]
		
		javaModels.forEach[javaModel | 
			enhanceInheritableElements(javaModel)
		]
		
		javaModels.forEach[javaModel | 
			model.relationships.addAll(generateRelationshipsFromJavaModel(javaModel))
		]
		
				
		System.err.println(
		'''
		existing orm relationship: 
		«FOR relationship : model.relationships»
		«relationship.name»
		«ENDFOR»
		''')
		
		
		javaModels.forEach[javaModel | 
			extendRelationshipsWithTargetFromJavaModel(javaModel)
		]
		
		return model
	}
	
	def void setJoinClassesAndEmbeddables(List<JavaModel> javaModels) {
		val List<JavaClass> classes = new ArrayList<JavaClass>
		
		javaModels.forEach[javaModel |
			classes.addAll(javaModel.eAllContents.filter(JavaClass).toList)
		]
		
		val entities = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Entity")].empty]
		val embeddables = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Embeddable")].empty]
		
		entities.forEach[clazz | 
			val Iterable<JavaElement> elements = clazz.elements.filter[element instanceof Statement]
			val JavaElement id = elements.findFirst[!annotations.filter[type.equals("EmbeddedId")].empty]
			
			
			if (id !== null && id.element instanceof Statement) {
				var embeddable = embeddables.findFirst[name.equals((id.element as Statement).type)]
				
				if (embeddable !== null) {
					val attributeNames = embeddable.elements.filter[element instanceof Statement].map[element.name].toSet
					
					val mapsIdNames = elements
						.filter[!annotations.filter[type.equals("MapsId")].empty]
						.map[annotations.findFirst[type.equals("MapsId")].options.head.option]
						.map[it.substring(1, it.length - 1)]
						.toSet
					
					if (attributeNames.containsAll(mapsIdNames) && !mapsIdNames.empty) {
						joinClasses.add(clazz)
						joinClassEmbeddedIds.add(embeddable)
					}
				}
			}
		]
	}
	
	
	def List<Embeddable> generateEmbeddablesFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val List<Embeddable> ret = new ArrayList<Embeddable>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Embeddable")].empty].filter[!joinClassEmbeddedIds.contains(it)]
		
		classes.forEach[clazz | 
			var Embeddable embeddable = OrmModelFactory.eINSTANCE.createEmbeddable
			embeddable.name = clazz.name
			embeddable.attributes.addAll(generateAttributesFromClass(clazz))
			ret.add(embeddable)
		]
		
		// TODO: Check if this is needed actually
//		classes.forEach[clazz |
//			var Embeddable embeddable = ret.findFirst[name.equals(clazz.name)]
//			embeddable.attributes.addAll(generateEmbeddedAttributesFromClass(clazz))
//			ret.add(embeddable)
//		]
		
		return ret
	}
	
	def List<MappedClass> generateMappedClassesFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val ret = new ArrayList<MappedClass>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("MappedSuperclass")].empty]
		
		classes.forEach[clazz | 
			var MappedClass mappedClass = OrmModelFactory.eINSTANCE.createMappedClass
			mappedClass.name = clazz.name
			mappedClass.attributes.addAll(generateAttributesFromClass(clazz))
			ret.add(mappedClass)
		]
		
		return ret
	}
	
	def List<Entity> generateEntitiesFromJavaModel(JavaModel javaModel, Boolean filterJoinClasses) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		if (filterJoinClasses) {
			classes = classes.filter[!joinClasses.contains(it)]
		} else {
			classes = classes.filter[joinClasses.contains(it)]
		}
		
		val ret = new ArrayList<Entity>
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Entity")].empty]
		
		classes.forEach[clazz | 
			var Entity ormEntity = OrmModelFactory.eINSTANCE.createEntity
			ormEntity.name = clazz.name
			ormEntity.attributes.addAll(generateAttributesFromClass(clazz))
			
			// HANDLE INHERITANCE OPTIONS
			val inheritanceAnnotation = (clazz.eContainer as JavaElement).annotations.findFirst[type.equals("Inheritance")]
			if (inheritanceAnnotation !== null) {
				val inheritanceStrategy = inheritanceAnnotation.options.filter[param.equals("strategy")].map[option].head
				if (inheritanceStrategy === null) {
					System.err.println('''ERROR: Invalid inheritance strategy for «clazz.name»''')
					return
				}
				val inheritanceOption = OrmModelFactory.eINSTANCE.createInheritanceOption
				inheritanceOption.option = switch (inheritanceStrategy){
					case "InheritanceType.JOINED": InheritanceStrategy.JOINED_TABLE
					case "InheritanceType.SINGLE_TABLE": InheritanceStrategy.SINGLE_TABLE
					case "InheritanceType.TABLE_PER_CLASS": InheritanceStrategy.TABLE_PER_CLASS
					default: InheritanceStrategy.UNDEFINED
				}
				ormEntity.options.add(inheritanceOption)
			}
			
			
			// HANDLE JOIN CLASS LOGIC
			if (joinClasses.contains(clazz)) {
				// Create whole join entity structure, except for attributeName, needs to be fetched at relationship time
				ormEntity.joinEntity = true
				var joinSource = OrmModelFactory.eINSTANCE.createRelationEntity
				var joinTarget = OrmModelFactory.eINSTANCE.createRelationEntity
				val joinStatements = clazz.elements
					.filter[element instanceof Statement]
					.filter[!annotations.filter[type.equals("MapsId")].empty]
					.map[(element as Statement)]
				val joinEntityNames = joinStatements.map[type].toList
				
				val joinSourceEntity = model.elements.filter(Entity).findFirst[name.equals(joinEntityNames.head)]
				val joinTargetEntity = model.elements.filter(Entity).findFirst[name.equals(joinEntityNames.last)]
				
				joinSource.entity = joinSourceEntity
				joinTarget.entity = joinTargetEntity
				
				ormEntity.joinSource = joinSource
				ormEntity.joinTarget = joinTarget
			}
			
			ret.add(ormEntity)
		]
		
		return ret
	}
	
	def void enhanceInheritableElements(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass).filter[!joinClasses.contains(it)]
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Entity") || type.equals("MappedSuperclass")].empty]
		
		classes.forEach[clazz | 
			
			// SET EXTENSIONS
			if (clazz.extends !== null) {
				val elem = model.elements.filter(InheritableElement).findFirst[name.equals(clazz.name)]
				val extendedElem = model.elements.filter(InheritableElement).findFirst[name.equals(clazz.extends)]
				if (elem === null){
					System.err.println('''ERROR: Could not find element for «clazz.name» to create extension''')
					return
				}
				if (extendedElem === null){
					System.err.println('''ERROR: Could not find extended element for «clazz.extends»''')
					return
				}
				
				elem.extends = extendedElem
			}
		]
	}
	
	
	def List<Attribute> generateAttributesFromClass(JavaClass javaClass){
		
		val ret = new ArrayList<Attribute>
		
		var elements = javaClass.elements.filter[element instanceof Statement]
		elements = elements.filter[annotations.filter[type.equals("ManyToOne") || type.equals("ManyToMany") || type.equals("OneToOne") || type.equals("OneToMany")].empty]
		
		// PRIMARY AND ENUM ATTRIBUTES

		var primaryElements = elements
			.filter[annotations.filter[type.equals("Embedded") || type.equals("EmbeddedId")].empty]
			.filter[!annotations.filter[type.equals("Column")].empty]
		
		
		primaryElements.forEach[element | 
			// Check if nullable
			var Boolean nullable = true
			val columnAnnotation = element.annotations.findFirst[it.type.equals("Column")]
			val nullableOption = columnAnnotation.options.findFirst[param.equals("nullable")]
			if (nullableOption !== null && nullableOption.option.equals("false")) {
				nullable = false
			}
			
			
			val type = (element.element as Statement).type
			val ormEnum = model.elements.filter(OrmEnum).findFirst[name.equals(type)]
			if (ormEnum !== null) {
				// CREATE ENUM ATTRIBUTE
				val EnumAttribute attribute = OrmModelFactory.eINSTANCE.createEnumAttribute
				attribute.name = (element.element as Statement).name
				attribute.enumType = ormEnum
				if (!nullable) { 
					attribute.type = AttributeType.REQUIRED
				}
				ret.add(attribute)
			} else {
				// CREATE PRIMARY ATTRIBUTE
				val DataAttribute attribute = OrmModelFactory.eINSTANCE.createDataAttribute
				attribute.datatype = switch ((element.element as Statement).type){
					case "UUID": DataType.UUID
					case "Boolean": DataType.BOOLEAN
					case "Integer": DataType.INT
					default: DataType.STRING
				}
				if (!element.annotations.filter[it.type.equals("Id")].empty){
					attribute.type = AttributeType.ID
				} else if (!nullable) { 
					attribute.type = AttributeType.REQUIRED
				}
				attribute.name = (element.element as Statement).name
				ret.add(attribute)
			}
		]
		
		// EMBEDDED ATTRIUBTES
		
		var embeddedElements = elements.filter[!annotations.filter[type.equals("Embedded") || type.equals("EmbeddedId")].empty]
		
		embeddedElements.forEach[element | 
			var EmbeddedAttribute attribute = OrmModelFactory.eINSTANCE.createEmbeddedAttribute
			val embeddable = Iterables.getFirst(model.elements.filter(Embeddable).filter[name.equals((element.element as Statement).type)], null)
			if (embeddable !== null){
				attribute.embeddedType = embeddable
				if (!element.annotations.filter[type.equals("Id") || type.equals("EmbeddedId")].empty){
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
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Entity")].empty]
		
		classes.forEach[clazz | 
			var relationships = clazz.elements.filter[element instanceof Statement]
			relationships = relationships.filter[!annotations.filter[type.equals("ManyToOne") || type.equals("ManyToMany") || type.equals("OneToOne") || type.equals("OneToMany")].empty]
			relationships = relationships.filter[!annotations.filter[type.equals("JoinColumn") || type.equals("JoinTable") || type.equals("JoinColumns")].empty]
			relationships.forEach[relationship |
				val sourceAttributeName = (relationship.element as Statement).name
				val sourceEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals(clazz.name)], null)
				System.err.println('''trying to generate relationship for «sourceEntity.name»: started''')
				
				// Check if source required
				var Boolean sourceRequired = false
				val relationAnnotation = relationship.annotations.findFirst[type.equals("ManyToOne") || type.equals("ManyToMany") || type.equals("OneToOne") || type.equals("OneToMany")]
				val optionalOption = relationAnnotation.options.findFirst[param.equals("optional")]
				if (optionalOption !== null && optionalOption.option.equals("false")) {
					sourceRequired = true // Counter-intuitive, but inverse logic applied
				}
				
				
				if (sourceEntity !== null) {
					val targetEntityName = (relationship.element as Statement).type.replaceAll("^[^<]*<|>$", "")
					val targetEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals(targetEntityName)], null)
					if (targetEntity !== null && !joinClasses.contains(clazz)){
						var Relationship ormRelationship = OrmModelFactory.eINSTANCE.createRelationship
							
						var RelationEntity source = OrmModelFactory.eINSTANCE.createRelationEntity
						source.attributeName = sourceAttributeName
						source.entity = sourceEntity
							
						var RelationEntity target = OrmModelFactory.eINSTANCE.createRelationEntity
						target.entity=targetEntity
							
						ormRelationship.source = source
						ormRelationship.target = target
						ormRelationship.name = sourceEntity.name+targetEntity.name
						ormRelationship.type =  switch (relationship.annotations){
							case !relationship.annotations.filter[type.equals("ManyToOne")].empty : RelationshipType.MANY_TO_ONE
							case !relationship.annotations.filter[type.equals("ManyToMany")].empty : RelationshipType.MANY_TO_MANY
							case !relationship.annotations.filter[type.equals("OneToOne")].empty : RelationshipType.ONE_TO_ONE
						}
						ormRelationship.unidirectional = true
						ormRelationship.sourceRequired = sourceRequired
						ret.add(ormRelationship)
					}
				}
			]
		]
		
		return ret
	}
	
	def void extendRelationshipsWithTargetFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		classes = classes.filter[!(eContainer as JavaElement).annotations.filter[type.equals("Entity")].empty]
		
		classes.forEach[clazz | 
			var relationships = clazz.elements.filter[element instanceof Statement]
			relationships = relationships.filter[!annotations.filter[type.equals("ManyToOne") || type.equals("ManyToMany") || type.equals("OneToOne") || type.equals("OneToMany")].empty]
			relationships = relationships.filter[annotations.filter[type.equals("JoinColumn") || type.equals("JoinTable") || type.equals("JoinColumns")].empty]
			relationships.forEach[relationship |				
				
				
				val targetAttributeName = (relationship.element as Statement).name
				val targetEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals(clazz.name)], null)
				val sourceEntityName = (relationship.element as Statement).type.replaceAll("^[^<]*<|>$", "")
				val sourceEntity = Iterables.getFirst(model.elements.filter(Entity).filter[name.equals(sourceEntityName)], null)
				
				if (sourceEntity === null || targetEntity === null) {
					return
				}
				
				System.err.println('''altering relationship between source «sourceEntity.name» and target «targetEntity.name»''')
				
				//catch special case of source being a join entity
				if (sourceEntity.joinEntity) {
					System.err.println("Special case triggered: " + targetAttributeName)
					if (sourceEntity.joinSource.attributeName === null) {
						sourceEntity.joinSource.attributeName = targetAttributeName
					} else {
						sourceEntity.joinTarget.attributeName = targetAttributeName
					}
				} 
				// continue with standard relationship
				else {
					var ormRelationship = model.relationships.findFirst[name.equals(sourceEntity.name+targetEntity.name)]
					if (ormRelationship === null ) {
						System.err.println("could not find existing relationship")
						return
					}
					ormRelationship.unidirectional = false
					ormRelationship.target.attributeName = targetAttributeName
				}
			]
		]
	}
	
	def List<OrmEnum> generateEnumsFromJavaModel(JavaModel javaModel) {
		var enums = javaModel.eAllContents.filter(JavaEnum)
		
		val List<OrmEnum> ret = new ArrayList<OrmEnum>
		
		enums.forEach[javaEnum | 
			val OrmEnum ormEnum = OrmModelFactory.eINSTANCE.createOrmEnum
			ormEnum.name = javaEnum.name
			javaEnum.values.forEach[value |
				val EnumValue ormEnumValue = OrmModelFactory.eINSTANCE.createEnumValue
				ormEnumValue.value = value
				ormEnum.values.add(ormEnumValue)
			]
			ret.add(ormEnum)
		]
		
		return ret
	}
	
}