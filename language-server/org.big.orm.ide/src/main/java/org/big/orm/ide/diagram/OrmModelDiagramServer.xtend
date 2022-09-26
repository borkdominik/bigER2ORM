package org.big.orm.ide.diagram

import org.eclipse.sprotty.xtext.LanguageAwareDiagramServer
import com.google.inject.Inject
import org.eclipse.sprotty.Action
import org.eclipse.sprotty.xtext.ReconnectAction

class OrmModelDiagramServer extends LanguageAwareDiagramServer {

	@Inject OrmModelReconnectHandler reconnectHandler
	
	override protected handleAction(Action action) {
		if (action.kind === ReconnectAction.KIND) 
			reconnectHandler.handle(action as ReconnectAction, this)
		else 
			super.handleAction(action)
	}
}