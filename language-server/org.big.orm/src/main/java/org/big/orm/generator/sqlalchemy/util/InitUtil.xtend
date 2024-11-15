package org.big.orm.generator.sqlalchemy.util


import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Singleton
import com.google.inject.Inject
import java.util.List
import java.util.TreeSet
import org.big.orm.ormModel.Relationship
import org.big.orm.ormModel.RelationshipType
import org.big.orm.ormModel.Entity

@Singleton
class InitUtil {
		
	@Inject extension ImportUtil importUtil;
	
	def compileEntityInit(Resource r) 
	'''
	«FOR initImport : r.generateInitImports»
	«initImport»
	«ENDFOR»
	
	__all__ = [
		«FOR definition : r.generateAllDefinition»
		'«definition»',
		«ENDFOR»
	]
	'''
	
	def List<String> generateAllDefinition(Resource resource) {
		val imports = new TreeSet<String>();
		
		for (relationship : resource.allContents.toIterable.filter(Relationship).filter[type === RelationshipType.MANY_TO_MANY && !attributes.empty]) {
			imports.add(relationship.name)
		}
		
		for (entity : resource.allContents.toIterable.filter(Entity)) {
			imports.add(entity.name)
		}
		
		return imports.toList;
	}
	
	def compileMainInit(Resource r)
	'''
	'''
	
	def compileBase(Resource r)
	'''
	from sqlalchemy.ext.declarative import declarative_base
	
	Base = declarative_base()
	'''
}