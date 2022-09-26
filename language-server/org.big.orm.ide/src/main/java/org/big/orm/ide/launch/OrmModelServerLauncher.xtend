package org.big.orm.ide.launch

import org.eclipse.sprotty.xtext.launch.DiagramServerLauncher

class OrmModelServerLauncher extends DiagramServerLauncher {
	
	override createSetup() {
		new OrmModelLanguageServerSetup
	}

	def static void main(String[] args) {
		new OrmModelServerLauncher().run(args)
	}
}