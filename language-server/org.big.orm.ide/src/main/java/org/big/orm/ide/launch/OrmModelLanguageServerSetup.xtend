package org.big.orm.ide.launch;

import com.google.gson.GsonBuilder
import com.google.inject.Module
import org.eclipse.elk.core.util.persistence.ElkGraphResourceFactory
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.sprotty.layout.ElkLayoutEngine
import org.eclipse.sprotty.server.json.EnumTypeAdapter
import org.eclipse.sprotty.xtext.launch.DiagramLanguageServerSetup
import org.eclipse.sprotty.xtext.ls.SyncDiagramServerModule
import org.eclipse.xtext.ide.server.ServerModule
import org.eclipse.xtext.util.Modules2
import org.eclipse.elk.alg.libavoid.options.LibavoidMetaDataProvider
import org.eclipse.elk.alg.layered.options.LayeredMetaDataProvider
import org.big.orm.ide.diagram.actions.CustomActionsFactory

class OrmModelLanguageServerSetup extends DiagramLanguageServerSetup {

	override void setupLanguages() {
		// initialize ELK with libavoid & layered algorithm
		ElkLayoutEngine.initialize(new LayeredMetaDataProvider, new LibavoidMetaDataProvider)
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('elkg', new ElkGraphResourceFactory)
	}

	override GsonBuilder configureGson(GsonBuilder gsonBuilder) {
		// register action type adapter factories
		return gsonBuilder
			.registerTypeAdapterFactory(new CustomActionsFactory)
			.registerTypeAdapterFactory(new EnumTypeAdapter.Factory)
	}

	override Module getLanguageServerModule() {
		Modules2.mixin(new ServerModule, new SyncDiagramServerModule)
	}

}