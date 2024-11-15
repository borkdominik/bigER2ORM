package org.big.orm.ide.command

import org.eclipse.xtext.ide.server.commands.IExecutableCommandService
import org.eclipse.xtext.ide.server.ILanguageServerAccess
import java.net.URLDecoder
import org.eclipse.emf.common.util.URI
import java.net.URL
import org.eclipse.xtext.resource.IResourceServiceProvider
import com.google.common.collect.Lists
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.lsp4j.ExecuteCommandParams
import org.eclipse.xtext.util.CancelIndicator
import java.util.Map
import org.eclipse.xtext.generator.trace.TraceRegionSerializer
import java.net.MalformedURLException
import java.nio.charset.StandardCharsets
import org.eclipse.xtext.generator.IGenerator2
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.parser.IEncodingProvider
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.generator.trace.TraceFileNameProvider
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import com.google.gson.Gson
import org.big.orm.language.javaModel.JavaModel
import org.apache.commons.io.FileUtils
import java.io.File
import org.big.orm.language.java.JavaModel2OrmModelConverter
import java.util.ArrayList
import com.google.inject.Inject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResourceFactory
import org.big.orm.generator.hibernate.HibernateGenerator
import org.big.orm.generator.sqlalchemy.SqlAlchemyGenerator
import com.google.inject.Injector
import org.big.orm.generator.sqlalchemy.SqlAlchemyModule
import com.google.inject.Guice

class ExecutableCommandService implements IExecutableCommandService {
  	
  	@Inject XtextResourceFactory xtextResourceFactory;
  	SqlAlchemyGenerator sqlAlchemyGenerator;
  	
  	new() {
  	  var Injector sqlAlchemyInjector = Guice.createInjector(new SqlAlchemyModule());
      this.sqlAlchemyGenerator = sqlAlchemyInjector.getInstance(SqlAlchemyGenerator);
  	}
	
	override List<String> initialize() {
		return Lists.newArrayList("big.orm.command.generate", "big.orm.command.reverse");
	}

	
	override Object execute(ExecuteCommandParams params, ILanguageServerAccess access, CancelIndicator cancelIndicator) {
		System.err.println("Received command");
		
		val arguments = parseArguments(params);

		if (params.getCommand().equals("big.orm.command.generate")) {

			val filePath = URLDecoder.decode(arguments.get("file"), StandardCharsets.UTF_8);
			val outputPath = URLDecoder.decode(arguments.get("outputPath"), StandardCharsets.UTF_8);
			
			var URL fileUrl = null;
			var URL outputUrl = null;
			try {
				fileUrl = new URL(filePath);
				outputUrl = new URL(outputPath);
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			val XtextResourceSet rs = new XtextResourceSet();
			
			val URI fileUri = URI.createFileURI(fileUrl.getPath());
			val Resource r = rs.getResource(fileUri, true);

			val JavaIoFileSystemAccess fsa = new JavaIoFileSystemAccess(
					IResourceServiceProvider.Registry.INSTANCE, new IEncodingProvider.Runtime(),
					new TraceFileNameProvider(), new TraceRegionSerializer());
			fsa.setOutputPath(outputUrl.getPath());

			if(arguments.get("language").equals("Hibernate")) {
				new HibernateGenerator().doGenerate(r, fsa, null);
			} else if(arguments.get("language").equals("SQLAlchemy")) {
				this.sqlAlchemyGenerator.doGenerate(r, fsa, null);
			} else {
				return "Unsupported language";
			}


			return "Generated code!";
		}
		
		if (params.getCommand().equals("big.orm.command.reverse")) {

			System.err.println("File: " + arguments.get("fileInput"));
			
			val filePath = URLDecoder.decode(arguments.get("fileInput"), StandardCharsets.UTF_8);
			val outputPath = URLDecoder.decode(arguments.get("fileOutput"), StandardCharsets.UTF_8);
			val modelName = arguments.get("modelName");
			
			var URL fileUrl = null;
			var URL outputUrl = null;
			try {
				fileUrl = new URL(filePath);
				outputUrl = new URL(outputPath + File.separatorChar + modelName + ".orm");
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			val XtextResourceSet rs = new XtextResourceSet();
			val Map<String, Object> extensionMap = rs.resourceFactoryRegistry.extensionToFactoryMap;
			extensionMap.put("orm", xtextResourceFactory);
			
			System.err.println("Valid file URI type: " + fileUrl.getPath())
			
			var file = new File(fileUrl.getPath)
			var outputFile = new File(outputUrl.getPath)
			var files = FileUtils.listFiles(file, #{"java"}, true)
			
			val models = new ArrayList<JavaModel>
			
			files.forEach[f |
				val URI fileUri = URI.createFileURI(f.absolutePath);
				val Resource r = rs.getResource(fileUri, true);
			
				models.add(r.allContents.toIterable.filter(JavaModel).head)
			]
			
			
			val JavaModel2OrmModelConverter javaConverter = new JavaModel2OrmModelConverter();
			var ormModel = javaConverter.generateOrmModelFromJavaModels(modelName, models)
			
			val JavaIoFileSystemAccess fsa = new JavaIoFileSystemAccess(
					IResourceServiceProvider.Registry.INSTANCE, new IEncodingProvider.Runtime(),
					new TraceFileNameProvider(), new TraceRegionSerializer());
			fsa.setOutputPath(outputUrl.getPath());
			var outResource = rs.createResource(URI.createFileURI(outputFile.absolutePath))
			outResource.contents.add(ormModel)
			
			outResource.save(SaveOptions.newBuilder.format.options.toOptionsMap)
			
			return "Generated Model";
		}
		
		return "Bad Command";

	}
	
	def Map<String, String> parseArguments(ExecuteCommandParams params) {
		val JsonObject json = params.getArguments().iterator().next() as JsonObject;
		val Gson gson = new Gson();
		return gson.fromJson(json, new TypeToken<Map<String, String>>() {}.getType());
	}
	
}