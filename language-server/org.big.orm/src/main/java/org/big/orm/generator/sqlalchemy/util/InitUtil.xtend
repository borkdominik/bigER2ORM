package org.big.orm.generator.sqlalchemy.util


import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Singleton
import com.google.inject.Inject
import java.util.List
import java.util.TreeSet
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
		
		for (entity : resource.allContents.toIterable.filter(Entity)) {
			imports.add(entity.name)
		}
		
		return imports.toList;
	}
	
	def compileMainInit()
	'''
	'''
	
	def compileBase()
	'''
	from sqlalchemy import create_engine
	from sqlalchemy.ext.declarative import declarative_base
	from sqlalchemy.orm import sessionmaker
	
	db_string = "postgresql://postgres:postgres@postgres:5432/python"
	
	db = create_engine(db_string)
	Base = declarative_base()
	
	Session = sessionmaker(db)
	'''
	
	def compileMain()
	'''
	import sqlalchemy
	
	from base import Base, db, Session
	from entity import *
	
	# Clean reset without noisy "doesn't exist" errors:
	Base.metadata.drop_all(bind=db, checkfirst=True)
	Base.metadata.create_all(bind=db, checkfirst=True)
	
	session = Session()
		
	with Session() as session:
		session.commit()
	'''


	def compileRequirements()
	'''
	sqlalchemy==2.0.35
	psycopg2-binary==2.9.9
	'''
}