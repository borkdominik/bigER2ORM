package org.big.orm.ide.command;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

import org.big.orm.generator.OrmModelGenerator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.lsp4j.ExecuteCommandParams;
import org.eclipse.xtext.generator.IGenerator2;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.ide.server.ILanguageServerAccess;
import org.eclipse.xtext.ide.server.commands.IExecutableCommandService;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.common.collect.Lists;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

public class CommandService implements IExecutableCommandService {
	@Override
	public List<String> initialize() {
		return Lists.newArrayList("big.orm.command.generate");
	}
	
	
	@Override
	public Object execute(ExecuteCommandParams params, ILanguageServerAccess access, CancelIndicator cancelIndicator) {
		System.err.println("Received command");
		if(params.getCommand().equals("big.orm.command.generate")) {
			
			Map<String, String> arguments = parseArguments(params);
			
			String path = URLDecoder.decode(arguments.get("file"), StandardCharsets.UTF_8);
			
			System.err.println("FILE_URI: "+ path);
			URL url = null;
			try {
				url = new URL(path);
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			System.err.println("URI: " + url.getPath());
			
			final XtextResourceSet rs = new XtextResourceSet();
			URI uri = URI.createFileURI(url.getPath());
			final Resource r = rs.getResource(uri, true);
			
			
			JavaIoFileSystemAccess fsa = new JavaIoFileSystemAccess();
			fsa.setOutputPath(uri.trimSegments(1).devicePath() + "/src-gen");
			
			IGenerator2 generator = new OrmModelGenerator();
			generator.doGenerate(r, fsa, null);
			 
			return "Received generate command!";
		}
		return "Bad Command";
	}
	
	private Map<String, String> parseArguments(ExecuteCommandParams params){
		JsonObject json = (JsonObject) params.getArguments().iterator().next();
		Gson gson = new Gson();
		return gson.fromJson(json, new TypeToken<Map<String, String>>(){}.getType());
	}
}