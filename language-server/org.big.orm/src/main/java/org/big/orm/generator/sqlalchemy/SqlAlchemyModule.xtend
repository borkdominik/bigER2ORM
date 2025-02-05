package org.big.orm.generator.sqlalchemy

import com.google.inject.AbstractModule
import org.big.orm.generator.sqlalchemy.util.AttributeUtil
import org.big.orm.generator.sqlalchemy.util.EmbeddableUtil
import org.big.orm.generator.sqlalchemy.util.ImportUtil
import org.big.orm.generator.sqlalchemy.util.InheritableUtil
import org.big.orm.generator.sqlalchemy.util.RelationshipUtil
import org.big.orm.generator.sqlalchemy.util.InitUtil
import org.big.orm.generator.common.CommonUtil

class SqlAlchemyModule extends AbstractModule {
	
	override protected void configure() {
      bind(AttributeUtil);
      bind(EmbeddableUtil);
      bind(ImportUtil);
      bind(InheritableUtil);
      bind(RelationshipUtil);
      bind(InitUtil);
      bind(CommonUtil);
   } 
}