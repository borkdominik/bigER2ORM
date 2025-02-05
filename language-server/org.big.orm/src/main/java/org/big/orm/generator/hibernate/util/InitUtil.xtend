package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton

@Singleton
class InitUtil {
	
	// TODO: Allow for db connection infos in code generation
	def compilePersistenceFile()
	'''
	<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
	<persistence xmlns="https://jakarta.ee/xml/ns/persistence"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="https://jakarta.ee/xml/ns/persistence https://jakarta.ee/xml/ns/persistence/orm/orm_3_1.xsd"
	  version="3.1">
	  <persistence-unit name="default">
	    <properties>
	      <property name="jakarta.persistence.jdbc.driver" value="org.postgresql.Driver"/>
	      <property name="jakarta.persistence.jdbc.url" value="jdbc:postgresql://localhost:5432/java"/>
	      <property name="jakarta.persistence.jdbc.user" value="postgres"/>
	      <property name="jakarta.persistence.jdbc.password" value="postgres"/>
	      <property name="hibernate.hbm2ddl.auto" value="create"/>
	      <property name="hibernate.physical_naming_strategy" value="org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy"/>
	    </properties>
	  </persistence-unit>
	</persistence>
	'''	
}