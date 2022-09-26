package org.big.orm.ide.launch

import org.eclipse.sprotty.xtext.launch.DiagramServerSocketLauncher

class OrmModelSocketServer extends DiagramServerSocketLauncher {

	override createSetup() {
		new OrmModelLanguageServerSetup
	}

	def static void main(String... args) {
		new OrmModelSocketServer().run(args)
	}
}