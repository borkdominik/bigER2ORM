package org.big.orm.ide.symbol;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.lsp4j.SymbolKind;
import org.big.orm.ormModel.OrmModelPackage;
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolMapper.DocumentSymbolKindProvider;


public class OrmDocumentSymbolKindProvider extends DocumentSymbolKindProvider {
	
	@Override
	protected SymbolKind getSymbolKind(EClass clazz) {
		if (clazz.getEPackage() == OrmModelPackage.eINSTANCE) {
			switch (clazz.getClassifierID()) {
				case OrmModelPackage.ORM_MODEL: return SymbolKind.Class;
				case OrmModelPackage.MODEL_ELEMENT: return SymbolKind.Object;
				case OrmModelPackage.RELATIONSHIP: return SymbolKind.Object;
				case OrmModelPackage.ATTRIBUTE: return SymbolKind.TypeParameter;
				default: return SymbolKind.Property;
			}
		}
		
		return super.getSymbolKind(clazz);
	}
}
