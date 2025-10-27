package org.big.orm.generator.sqlalchemy.util

import java.util.HashMap
import java.util.TreeSet
import java.util.stream.Stream
import java.util.stream.Collectors
import java.util.Map
import java.util.List
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.DataAttribute
import org.big.orm.ormModel.DataType
import org.big.orm.ormModel.AttributeType
import org.big.orm.ormModel.InheritableElement
import java.util.ArrayList
import org.big.orm.ormModel.OrmModel
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.MappedClass
import com.google.common.base.CaseFormat
import org.big.orm.ormModel.InheritanceStrategy
import org.big.orm.ormModel.EmbeddedAttribute
import org.big.orm.ormModel.RelationshipType
import com.google.inject.Singleton
import com.google.inject.Inject
import org.big.orm.ormModel.Attribute
import org.eclipse.emf.ecore.resource.Resource
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.EnumAttribute

@Singleton
class ImportUtil {
	
	@Inject extension CommonUtil commonUtil;
	
	
	def List<String> generateImports(InheritableElement e) {
		val imports = new TreeSet<String>();
		val importFroms = new HashMap<String, TreeSet<String>>();
		val finalFromImports = new TreeSet<String>();
		
		// PREPARE RELATIONS
		
		val elementSourceRelations = new ArrayList<Relationship>();
		val elementTargetRelations = new ArrayList<Relationship>();
		
		for(r : (e.eContainer as OrmModel).relationships){
			if (r.source.entity.name.equals(e.name)) {
				elementSourceRelations.add(r)
			}
			if (r.target.entity.name.equals(e.name) && !r.unidirectional){
				elementTargetRelations.add(r)
			}
		}
		
		// GENERAL ATTRIBUTE IMPORTS
		
		addImportsForAttributes(e.attributes, imports, importFroms)
		
		// INHERITANCE IMPORTS
		
		if (e instanceof Entity && (e.extends === null || !(e.extends instanceof Entity))) {
			addFromImport(importFroms, "base", "Base");
		}
		
		if (e instanceof MappedClass) {
			addFromImport(importFroms, "sqlalchemy.orm", "declarative_mixin")
		}
		
		if (e instanceof Entity) {
			val strategy = e.inheritanceStrategy
			
			if (e.extends !== null) {
				if(!(strategy === InheritanceStrategy.TABLE_PER_CLASS && e.extends instanceof MappedClass)){
					addFromImport(importFroms, "entity." + CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.extends.name), e.extends.name);
				}

				if (strategy === InheritanceStrategy.SINGLE_TABLE && e.extends instanceof MappedClass) {
					addFromImport(importFroms, "sqlalchemy.orm", "mapped_column");
					addFromImport(importFroms, "sqlalchemy", "String");
				}
				
				if (strategy === InheritanceStrategy.TABLE_PER_CLASS) {
					var InheritableElement currentElement = e
					do {
						currentElement = currentElement.extends
						addImportsForAttributes(currentElement.attributes, imports, importFroms)
					} while (currentElement.extends !== null)
				}
				
				if (strategy === InheritanceStrategy.JOINED_TABLE && e.extends instanceof Entity) {
					addFromImport(importFroms, "sqlalchemy", "ForeignKeyConstraint");
					if (e !== e.rootElement) {
						addFromImport(importFroms, "sqlalchemy.orm", "column_property")
						var ArrayList<Attribute> joinedKeyAttributes = new ArrayList<Attribute>();
						joinedKeyAttributes.add(e.keyAttribute)
						addImportsForAttributes(joinedKeyAttributes, imports, importFroms)
					}
				}
			}
			
			if (strategy === InheritanceStrategy.TABLE_PER_CLASS) {
				if (e.extends === null || e.extends instanceof MappedClass){
					addFromImport(importFroms, "sqlalchemy.ext.declarative", "ConcreteBase");	
				}
			}
			
			// JOIN ENTITY
			if (e.joinEntity) {
				addFromImport(importFroms, "sqlalchemy", "PrimaryKeyConstraint");	
			}
		}
		
			
		// RELATIONSHIP IMPORTS
		
		if (!elementSourceRelations.empty) {
			addFromImport(importFroms, "sqlalchemy.orm", "relationship");
			addFromImport(importFroms, "sqlalchemy.orm", "Mapped");
			val xToOneSourceRelations = elementSourceRelations.filter[relation | (relation.type == RelationshipType.MANY_TO_ONE) || (relation.type == RelationshipType.ONE_TO_ONE)];
			if (!xToOneSourceRelations.empty){
				addFromImport(importFroms, "sqlalchemy", "ForeignKeyConstraint");
				addFromImport(importFroms, "sqlalchemy.orm", "mapped_column");
				for (Relationship xToOneSourceRelation : xToOneSourceRelations){
					var DataAttribute idAttribute = xToOneSourceRelation.target.entity.allAttributes.filter(DataAttribute).filter[type == AttributeType.ID].head
					if (idAttribute !== null && idAttribute.datatype === DataType.UUID) {
						imports.add("import uuid");
						addFromImport(importFroms, "sqlalchemy", "UUID");
					}
				}
			}
		}
		
		if (!elementTargetRelations.empty) {
			addFromImport(importFroms, "sqlalchemy.orm", "relationship");
			addFromImport(importFroms, "sqlalchemy.orm", "Mapped");
		}
		
		for (Relationship r: elementSourceRelations.filter[relation | relation.type == RelationshipType.MANY_TO_MANY]) {
			var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
			addFromImport(importFroms, "entity." + tableName + "_table", tableName);
		}
		
		for (Relationship r: elementTargetRelations.filter[relation | relation.type == RelationshipType.MANY_TO_MANY]) {
			var String tableName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, r.name)
			addFromImport(importFroms, "entity." + tableName + "_table", tableName);
		}
		
		if (!elementSourceRelations.filter[relation | relation.type === RelationshipType.ONE_TO_ONE].empty) {
			addFromImport(importFroms, "sqlalchemy", "UniqueConstraint")
		}
		
		
		// Parse importFroms at end of import generation
		
		for (Map.Entry<String, TreeSet<String>> entry : importFroms.entrySet) {
			finalFromImports.add("from " + entry.key +  " import " + String.join(", ", entry.value))
		}
		
		return Stream.concat(imports.toList.stream, finalFromImports.toList.stream).collect(Collectors.toList);
	}
	
	def List<String> generateInitImports(Resource resource) {
		val importFroms = new HashMap<String, TreeSet<String>>();
		val finalFromImports = new TreeSet<String>();
		var String fileName;
		
		for (entity : resource.allContents.toIterable.filter(Entity)) {
			fileName = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, entity.name)
			addFromImport(importFroms, "entity." + fileName, entity.name)
		}
		
		// Parse importFroms at end of import generation
		for (Map.Entry<String, TreeSet<String>> entry : importFroms.entrySet) {
			finalFromImports.add("from " + entry.key +  " import " + String.join(", ", entry.value))
		}
		
		return finalFromImports.toList;
	}
	
	private def void addImportsForAttributes(List<Attribute> attributes, TreeSet<String> imports, HashMap<String, TreeSet<String>> importFroms){
		
		// GENERAL ATTRIBUTE IMPORTS
		
		if (!attributes.filter(DataAttribute).empty) {
			addFromImport(importFroms, "sqlalchemy.orm", "Mapped");
			addFromImport(importFroms, "sqlalchemy.orm", "mapped_column");
		}
		
		if (!attributes.filter(EmbeddedAttribute).empty) {
			addFromImport(importFroms, "sqlalchemy.orm", "Mapped");
			addFromImport(importFroms, "sqlalchemy.orm", "composite");
			
			for(EmbeddedAttribute embeddedAttribute : attributes.filter(EmbeddedAttribute)){
				addFromImport(importFroms, "entity." + CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, embeddedAttribute.embeddedType.name), embeddedAttribute.embeddedType.name)
				addImportsForAttributes(embeddedAttribute.embeddedType.attributes, imports, importFroms)
			}
		}
		
		if (!attributes.filter(EnumAttribute).empty) {
			addFromImport(importFroms, "sqlalchemy.orm", "mapped_column");
			addFromImport(importFroms, "sqlalchemy", "Enum");
			for (EnumAttribute enumAttribute : attributes.filter(EnumAttribute)) {
				addFromImport(importFroms, "entity." + CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, enumAttribute.enumType.name), enumAttribute.enumType.name)
			}
		}
		
		// ATTRIBUTE TYPE IMPORTS
		
		if (!attributes.filter(DataAttribute).filter[datatype == DataType.UUID].empty) {
			imports.add("import uuid");
			addFromImport(importFroms, "sqlalchemy", "UUID");
		}
		
		if (!attributes.filter(DataAttribute).filter[datatype == DataType.INT].empty) {
			addFromImport(importFroms, "sqlalchemy", "Integer");
		}
		
		if (!attributes.filter(DataAttribute).filter[datatype == DataType.STRING].empty) {
			addFromImport(importFroms, "sqlalchemy", "String");
		}
		
		if (!attributes.filter(DataAttribute).filter[datatype == DataType.BOOLEAN].empty) {
			addFromImport(importFroms, "sqlalchemy", "Boolean");
		}
	}
	
	private def addFromImport(HashMap<String, TreeSet<String>> importMap, String fromValue, String importValue) {
			val params = importMap.getOrDefault(fromValue, new TreeSet<String>())
			params.add(importValue)
			importMap.put(fromValue, params)
	}
}