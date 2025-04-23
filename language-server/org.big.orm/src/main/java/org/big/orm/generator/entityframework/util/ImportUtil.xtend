package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import org.big.orm.ormModel.ModelElement
import java.util.TreeSet
import org.big.orm.ormModel.Entity
import org.big.orm.ormModel.InheritanceStrategy
import org.big.orm.ormModel.DataType
import org.big.orm.ormModel.AttributeType
import com.google.inject.Inject
import org.big.orm.generator.common.CommonUtil
import org.big.orm.ormModel.InheritableElement

@Singleton
class ImportUtil {
	
	@Inject extension CommonUtil commonUtil;
	
	def generateImports(ModelElement e) {
		val imports = new TreeSet<String>();
		
		// Primary Keys
		if(!e.attributes.filter[attribute | attribute.type === AttributeType.ID].empty){	
			imports.add("Microsoft.EntityFrameworkCore");
		}
		
		// Table Annotation
		if (e.needsTableAnnotation) {
			imports.add("System.ComponentModel.DataAnnotations.Schema");
		}
		
		// String DataType Annotation
		if (e instanceof InheritableElement) {
			if (!e.attributes.allAttributesAsDataAttributes.filter[attribute | attribute.datatype === DataType.STRING].empty) {
				imports.add("System.ComponentModel.DataAnnotations.Schema");
			}
		}
		
		return imports;
	}
	
	def Boolean needsTableAnnotation(ModelElement e) {
		if (e instanceof Entity) {
			return (e.rootElement === e || e.inheritanceStrategy === InheritanceStrategy.TABLE_PER_CLASS || e.inheritanceStrategy === InheritanceStrategy.JOINED_TABLE);
		} else {
			return false;
		}
	}
}