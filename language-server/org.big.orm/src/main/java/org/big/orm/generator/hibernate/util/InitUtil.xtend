package org.big.orm.generator.hibernate.util

import com.google.inject.Singleton
import org.big.orm.ormModel.OrmModel

@Singleton
class InitUtil {
	
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
	      <property name="jakarta.persistence.jdbc.url" value="jdbc:postgresql://postgres:5432/java"/>
	      <property name="jakarta.persistence.jdbc.user" value="postgres"/>
	      <property name="jakarta.persistence.jdbc.password" value="postgres"/>
	      <property name="jakarta.persistence.schema-generation.database.action" value="create"/>
	      <property name="hibernate.physical_naming_strategy" value="org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy"/>
	    </properties>
	  </persistence-unit>
	</persistence>
	'''	
	
	def compilePomXmlFile(OrmModel model)
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0"
	  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	  <modelVersion>4.0.0</modelVersion>
	
	  <groupId>com.bigorm</groupId>
	  <artifactId>«model.name»</artifactId>
	  <version>1.0-SNAPSHOT</version>
	  <name>«model.name»</name>
	
	  <properties>
	    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	    <maven.compiler.release>17</maven.compiler.release>
	    <maven.compiler.source>17</maven.compiler.source>
	    <maven.compiler.target>17</maven.compiler.target>
	  </properties>
	
	  <dependencies>
	
	    <dependency>
	      <groupId>org.hibernate.orm</groupId>
	      <artifactId>hibernate-core</artifactId>
	      <version>6.3.1.Final</version>
	    </dependency>
	
	    <dependency>
	      <groupId>jakarta.persistence</groupId>
	      <artifactId>jakarta.persistence-api</artifactId>
	      <version>3.1.0</version>
	    </dependency>
	
	    <dependency>
	      <groupId>org.postgresql</groupId>
	      <artifactId>postgresql</artifactId>
	      <version>42.7.7</version>
	    </dependency>
	
	    <dependency>
	      <groupId>org.projectlombok</groupId>
	      <artifactId>lombok</artifactId>
	      <version>1.18.30</version>
	    </dependency>
	
	  </dependencies>
	
	  <build>
	    <plugins>
	    </plugins>
	  </build>
	</project>
	'''
	
	def compileGenerateDatabase()
	'''
	import jakarta.persistence.EntityManager;
	import jakarta.persistence.EntityManagerFactory;
	import jakarta.persistence.Persistence;
	
	public class GenerateDatabase {
	  public static void main(String[] args) {
	    EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("default");
	    EntityManager entityManager = entityManagerFactory.createEntityManager();
	
	    entityManagerFactory.close();
	  }
	}
	'''
	
	def compileAbstractEnumConverter()
	'''
	package entity.util;
	
	import jakarta.persistence.AttributeConverter;
	
	public abstract class AbstractEnumConverter<E extends Enum<E>> implements AttributeConverter<E, String> {
	
	  private final Class<E> enumClass;
	
	  protected AbstractEnumConverter(Class<E> enumClass) {
	    this.enumClass = enumClass;
	  }
	
	  @Override public String convertToDatabaseColumn(E attribute) {
	    return attribute == null ? null : attribute.name();
	  }
	
	  @Override public E convertToEntityAttribute(String dbData) {
	    return dbData == null ? null : Enum.valueOf(enumClass, dbData);
	  }
	}
	'''
}