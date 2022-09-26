package org.big.orm.ide.command;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

import org.big.orm.generator.hibernate.HibernateOrmModelGenerator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.lsp4j.ExecuteCommandParams;
import org.eclipse.xtext.generator.IGenerator2;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.generator.trace.TraceFileNameProvider;
import org.eclipse.xtext.generator.trace.TraceRegionSerializer;
import org.eclipse.xtext.ide.server.ILanguageServerAccess;
import org.eclipse.xtext.ide.server.commands.IExecutableCommandService;
import org.eclipse.xtext.parser.IEncodingProvider;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.common.collect.Lists;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

public class CommandService implements IExecutableCommandService {
	
//	@Inject
	private IGenerator2 generator = new HibernateOrmModelGenerator();

	
	@Override
	public List<String> initialize() {
		return Lists.newArrayList("big.orm.command.generate");
	}

	@Override
	public Object execute(ExecuteCommandParams params, ILanguageServerAccess access, CancelIndicator cancelIndicator) {
		System.err.println("Received command");

		if (params.getCommand().equals("big.orm.command.generate")) {

			Map<String, String> arguments = parseArguments(params);

			String filePath = URLDecoder.decode(arguments.get("file"), StandardCharsets.UTF_8);
			String outputPath = URLDecoder.decode(arguments.get("output-path"), StandardCharsets.UTF_8);
			
			System.err.println("FILE_PATH: " + filePath);
			System.err.println("OUTPUT_PATH: " + outputPath);
			URL fileUrl = null;
			URL outputUrl = null;
			try {
				fileUrl = new URL(filePath);
				outputUrl = new URL(outputPath);
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			System.err.println("FILE_URL: " + fileUrl.getPath());
			System.err.println("OUTPUT_URL: " + outputUrl.getPath());

			final XtextResourceSet rs = new XtextResourceSet();
			
			URI fileUri = URI.createFileURI(fileUrl.getPath());
			final Resource r = rs.getResource(fileUri, true);

			JavaIoFileSystemAccess fsa = new JavaIoFileSystemAccess(
					IResourceServiceProvider.Registry.INSTANCE, new IEncodingProvider.Runtime(),
					new TraceFileNameProvider(), new TraceRegionSerializer());
			fsa.setOutputPath(outputUrl.getPath());

			generator.doGenerate(r, fsa, null);

			return "Generated code!";
		}
		return "Bad Command";

	}

	private Map<String, String> parseArguments(ExecuteCommandParams params) {
		JsonObject json = (JsonObject) params.getArguments().iterator().next();
		Gson gson = new Gson();
		return gson.fromJson(json, new TypeToken<Map<String, String>>() {
		}.getType());
	}
}