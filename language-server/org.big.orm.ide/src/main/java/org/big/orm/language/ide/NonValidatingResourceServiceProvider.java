package org.big.orm.language.ide;

import org.eclipse.xtext.resource.impl.DefaultResourceServiceProvider;
import org.eclipse.xtext.validation.IResourceValidator;

public class NonValidatingResourceServiceProvider extends DefaultResourceServiceProvider {

	@Override
    public IResourceValidator getResourceValidator() {
        return IResourceValidator.NULL;
    }
	
}
