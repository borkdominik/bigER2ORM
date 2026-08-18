package org.big.orm.ide.generator

import java.io.File
import java.util.ArrayList
import org.big.orm.OrmModelStandaloneSetup
import org.big.orm.language.java.JavaModelStandaloneSetup
import org.big.orm.language.java.JavaModel2OrmModelConverter
import org.big.orm.language.java.javaModel.JavaModel
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
import com.google.inject.Injector
import org.apache.commons.io.FileUtils

class StandaloneReverseMain {
	
	def static void main(String[] args) {
		if (args.length < 3) {
			System.err.println("Usage: StandaloneReverseMain <path-to-java-src-dir> <output-orm-file-path> <model-name>")
			System.exit(1)
		}
		
		val inputDirPath = args.get(0)
		val outputOrmFilePath = args.get(1)
		val modelName = args.get(2)
		
		val Injector injector = new JavaModelStandaloneSetup().createInjectorAndDoEMFRegistration()
		val xtextResourceFactory = injector.getInstance(XtextResourceFactory)
		
		val XtextResourceSet rs = new XtextResourceSet()
		val extensionMap = rs.resourceFactoryRegistry.extensionToFactoryMap
		extensionMap.put("java", xtextResourceFactory)
		
		val inputDir = new File(inputDirPath)
		val outputFile = new File(outputOrmFilePath)
		
		if (!inputDir.exists()) {
			System.err.println("Input directory does not exist: " + inputDirPath)
			System.exit(1)
		}
		
		val files = FileUtils.listFiles(inputDir, #{"java"}, true)
		val models = new ArrayList<JavaModel>()
		
		files.forEach[f |
			val URI fileUri = URI.createFileURI(f.absolutePath)
			val Resource r = rs.getResource(fileUri, true)
			val javaModel = r.allContents.toIterable.filter(JavaModel).head
			if (javaModel !== null) {
				models.add(javaModel)
			}
		]
		
		val JavaModel2OrmModelConverter javaConverter = new JavaModel2OrmModelConverter()
		val ormModel = javaConverter.generateOrmModelFromJavaModels(modelName, models)
		
		OrmModelStandaloneSetup.doSetup()
		val ormRs = new XtextResourceSet()
		val outResource = ormRs.createResource(URI.createFileURI(outputFile.absolutePath))
		outResource.contents.add(ormModel)
		
		outputFile.parentFile?.mkdirs()
		outResource.save(SaveOptions.newBuilder.format.options.toOptionsMap)
		
		if (!javaConverter.mappingWarnings.empty) {
			val sb = new StringBuilder("\n\n// non-reversable:")
			javaConverter.mappingWarnings.forEach[w |
				sb.append("\n// - ").append(w)
			]
			sb.append("\n")
			FileUtils.writeStringToFile(outputFile, sb.toString, "UTF-8", true)
		}
		
		System.out.println("Reverse engineered ORM model written to: " + outputFile.absolutePath)
	}
}
