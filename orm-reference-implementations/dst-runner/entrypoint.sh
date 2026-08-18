#!/bin/sh
set -e

echo "1. Copying DST source files and resources"
mkdir -p /app/src/main/java/dst/ass1/jpa /app/src/main/resources/META-INF
cp -r /app/dst-src/dst/ass1/jpa/model /app/src/main/java/dst/ass1/jpa/
cp -r /app/dst-src/dst/ass1/jpa/util /app/src/main/java/dst/ass1/jpa/
cp -r /app/dst-src/dst/ass1/jpa/listener /app/src/main/java/dst/ass1/jpa/
cp -r /app/runner-src/* /app/src/main/java/
cp -r /app/dst-res/* /app/src/main/resources/
cp /app/runner-res/persistence.xml /app/src/main/resources/META-INF/persistence.xml
cp /app/runner-res/orm.xml /app/src/main/resources/META-INF/orm.xml

echo "2. Transforming javax to jakarta"
find /app/src/main/java -name '*.java' -exec sed -i 's/javax\.persistence/jakarta\.persistence/g' {} +
find /app/src/main/java -name '*.java' -exec sed -i 's/javax\.validation/jakarta\.validation/g' {} +
sed -i 's/@EntityListeners/@jakarta.persistence.Entity\n@EntityListeners/g' /app/src/main/java/dst/ass1/jpa/model/impl/Trip.java
find /app/src/main/java -name '*.java' -exec sed -i '/@NamedQueries/,/})/d' {} +
find /app/src/main/java -name '*.java' -exec sed -i '/@NamedQuery/d' {} +

echo "3. Transforming XML namespaces to Jakarta EE 3.0"
find /app/src/main/resources -name '*.xml' -exec sed -i 's|http://java.sun.com/xml/ns/persistence/orm_2_0.xsd|https://jakarta.ee/xml/ns/persistence/orm/orm_3_0.xsd|g' {} +
find /app/src/main/resources -name '*.xml' -exec sed -i 's|http://xmlns.jcp.org/xml/ns/persistence/orm_2_0.xsd|https://jakarta.ee/xml/ns/persistence/orm/orm_3_0.xsd|g' {} +
find /app/src/main/resources -name '*.xml' -exec sed -i 's|http://java.sun.com/xml/ns/persistence|https://jakarta.ee/xml/ns/persistence|g' {} +
find /app/src/main/resources -name '*.xml' -exec sed -i 's|http://xmlns.jcp.org/xml/ns/persistence|https://jakarta.ee/xml/ns/persistence|g' {} +
find /app/src/main/resources -name '*.xml' -exec sed -i 's|version="2.0"|version="3.0"|g' {} +

echo "4. Compiling and running GenerateDatabase"
mvn -DskipTests compile exec:java -Dexec.mainClass=GenerateDatabase
