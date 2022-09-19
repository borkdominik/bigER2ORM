package org.big.orm.ide.symbol

import org.eclipse.xtext.ide.server.symbol.DocumentSymbolMapper.DocumentSymbolNameProvider
import org.eclipse.emf.ecore.EObject
import org.big.orm.ormModel.OrmModel
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.Attribute


class OrmDocumentSymbolNameProvider extends DocumentSymbolNameProvider {
	
	override getName(EObject object) {
		switch object {
			OrmModel: return object.name
			Entity: return object.name
			Attribute: return object.name
			default: return super.getName(object)
		}
	}
	
}