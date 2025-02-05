package org.big.orm.generator.hibernate

import com.google.inject.AbstractModule
import org.big.orm.generator.hibernate.util.InheritableUtil
import org.big.orm.generator.hibernate.util.ImportUtil
import org.big.orm.generator.hibernate.util.RelationshipUtil
import org.big.orm.generator.hibernate.util.AttributeUtil
import org.big.orm.generator.hibernate.util.InitUtil
import org.big.orm.generator.common.CommonUtil

class HibernateModule extends AbstractModule {
	
	override protected void configure() {
		bind(InheritableUtil);
		bind(ImportUtil);
		bind(RelationshipUtil);
		bind(AttributeUtil);
		bind(InitUtil);
		bind(CommonUtil);
   } 
}