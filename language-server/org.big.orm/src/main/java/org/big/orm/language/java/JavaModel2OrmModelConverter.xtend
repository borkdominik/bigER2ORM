package org.big.orm.language.java

import org.big.orm.ormModel.OrmModel
import org.big.orm.language.javaModel.JavaModel
import java.util.List
import org.big.orm.ormModel.OrmModelFactory
import org.big.orm.language.javaModel.JavaElement
import org.big.orm.ormModel.ModelElement
import java.util.ArrayList
import org.big.orm.language.javaModel.JavaClass
import org.big.orm.ormModel.Attribute
import org.big.orm.language.javaModel.Statement
import org.big.orm.ormModel.DataType

class JavaModel2OrmModelConverter {
	
	def OrmModel generateOrmModelFromJavaModels(String name, List<JavaModel> javaModels){
		
		val model = OrmModelFactory.eINSTANCE.createOrmModel()
		
		model.name = name
		
		
		javaModels.forEach[javaModel | 
			model.elements.addAll(generateModelElementsFromJavaModel(javaModel))
		]
		
		return model
	}
	
	
	def List<ModelElement> generateModelElementsFromJavaModel(JavaModel javaModel) {
		var classes = javaModel.eAllContents.filter(JavaClass)
		
		val ret = new ArrayList<ModelElement>
		
		var elements = classes.filter[!(eContainer as JavaElement).annotations.filter[name.equals("Entity") || name.equals("Embeddable")].empty]
		
		elements.forEach[element | 
			var ModelElement ormEntity = null
			if(!(element.eContainer as JavaElement).annotations.filter[name.equals("Entity")].empty){
				ormEntity = OrmModelFactory.eINSTANCE.createEntity
			} else {
				ormEntity = OrmModelFactory.eINSTANCE.createEmbeddable
			}
			ormEntity.name = element.name
			ormEntity.attributes.addAll(generateAttributesFromClass(element))
			ret.add(ormEntity)
		]
		
		return ret
	}
	
	def List<Attribute> generateAttributesFromClass(JavaClass javaClass){
		
		val ret = new ArrayList<Attribute>
		
		var elements = javaClass.elements.filter[element instanceof Statement]
		
		elements.forEach[element | 
			var attribute = OrmModelFactory.eINSTANCE.createDataAttribute
			attribute.name = (element.element as Statement).name
			attribute.datatype = DataType.STRING
			ret.add(attribute)
		]
		
		return ret
	}
	
	
}