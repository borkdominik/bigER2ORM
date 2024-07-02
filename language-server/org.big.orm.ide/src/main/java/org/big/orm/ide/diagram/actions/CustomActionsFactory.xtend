package org.big.orm.ide.diagram.actions

import org.eclipse.sprotty.xtext.EditActionTypeAdapterFactory
import org.eclipse.sprotty.MoveAction

/**
 * Factory to process custom actions on the server
 */
class CustomActionsFactory extends EditActionTypeAdapterFactory {

	new() {
		addActionKind(MoveAction.KIND, MoveAction)
	}
}