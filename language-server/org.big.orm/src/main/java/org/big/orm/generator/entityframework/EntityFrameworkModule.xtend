package org.big.orm.generator.entityframework

import com.google.inject.AbstractModule
import org.big.orm.generator.common.CommonUtil
import org.big.orm.generator.entityframework.util.InheritableUtil
import org.big.orm.generator.entityframework.util.InitUtil
import org.big.orm.generator.entityframework.util.ImportUtil
import org.big.orm.generator.entityframework.util.AttributeUtil
import org.big.orm.generator.entityframework.util.ModelUtil

class EntityFrameworkModule extends AbstractModule {
	
	override protected void configure() {
		bind(AttributeUtil);
		bind(InheritableUtil);
		bind(InitUtil);
		bind(ImportUtil);
		bind(ModelUtil);
		bind(CommonUtil);
   } 
}