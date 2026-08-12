package org.big.orm.ide.generator

import org.big.orm.OrmModelStandaloneSetup
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.parser.IEncodingProvider
import org.eclipse.xtext.generator.trace.TraceFileNameProvider
import org.eclipse.xtext.generator.trace.TraceRegionSerializer
import com.google.inject.Guice
import org.big.orm.generator.hibernate.HibernateModule
import org.big.orm.generator.hibernate.HibernateGenerator
import org.big.orm.generator.sqlalchemy.SqlAlchemyModule
import org.big.orm.generator.sqlalchemy.SqlAlchemyGenerator
import org.big.orm.generator.entityframework.EntityFrameworkModule
import org.big.orm.generator.entityframework.EntityFrameworkGenerator
import java.io.File

class StandaloneGeneratorMain {
	
	def static void main(String[] args) {
		if (args.length < 2) {
			System.err.println("Usage: StandaloneGeneratorMain <path-to-.orm-file> <output-directory> [Hibernate|SQLAlchemy|Entity Framework|all]")
			System.exit(1)
		}
		
		val ormFilePath = args.get(0)
		val outputDirPath = args.get(1)
		val language = if (args.length >= 3) args.get(2) else "all"
		
		// 1. Initialize EMF & Xtext Standalone Registration
		OrmModelStandaloneSetup.doSetup()
		
		val baseOutputDir = new File(outputDirPath).absolutePath
		val file = new File(ormFilePath).absolutePath
		
		// Load a fresh Resource for each target generator to avoid model mutation side effects across generators
		if (language.equalsIgnoreCase("all") || language.equals("Hibernate")) {
			val r = loadResource(file)
			val fsa = createFileSystemAccess(baseOutputDir + File.separator + "hibernate")
			val hibernateGen = Guice.createInjector(new HibernateModule()).getInstance(HibernateGenerator)
			hibernateGen.doGenerate(r, fsa, null)
			System.out.println("Generated Hibernate code in: " + baseOutputDir + File.separator + "hibernate")
		}
		
		if (language.equalsIgnoreCase("all") || language.equals("SQLAlchemy")) {
			val r = loadResource(file)
			val fsa = createFileSystemAccess(baseOutputDir + File.separator + "sql-alchemy")
			val sqlAlchemyGen = Guice.createInjector(new SqlAlchemyModule()).getInstance(SqlAlchemyGenerator)
			sqlAlchemyGen.doGenerate(r, fsa, null)
			System.out.println("Generated SQLAlchemy code in: " + baseOutputDir + File.separator + "sql-alchemy")
		}
		
		if (language.equalsIgnoreCase("all") || language.equals("Entity Framework")) {
			val r = loadResource(file)
			val fsa = createFileSystemAccess(baseOutputDir + File.separator + "entity-framework")
			val efGen = Guice.createInjector(new EntityFrameworkModule()).getInstance(EntityFrameworkGenerator)
			efGen.doGenerate(r, fsa, null)
			System.out.println("Generated Entity Framework code in: " + baseOutputDir + File.separator + "entity-framework")
		}
	}
	
	def private static Resource loadResource(String filePath) {
		val XtextResourceSet rs = new XtextResourceSet()
		val fileUri = URI.createFileURI(filePath)
		return rs.getResource(fileUri, true)
	}
	
	def private static JavaIoFileSystemAccess createFileSystemAccess(String outputPath) {
		val fsa = new JavaIoFileSystemAccess(
			IResourceServiceProvider.Registry.INSTANCE,
			new IEncodingProvider.Runtime(),
			new TraceFileNameProvider(),
			new TraceRegionSerializer()
		)
		fsa.setOutputPath(outputPath)
		return fsa
	}
}
