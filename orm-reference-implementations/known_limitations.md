# About

The following document summarizes all gaps in the current implementation.

## General

### Enum support

bigORM supports creation of enums, however with two key limitations: 
* only support for simple enums without additional attributes stored
* enums are always stored as ``varchar`` with fixed length

## EF Core

### PK not renameable in inheritance
In inheritance, it is not possible to rename primary keys. As a resolution all primary keys in EF Core are default and therefore different to SQL Alchemy and Hibernate

### No support for embeddables
In inherited classes, there is no support for complex types / owned (the EF Core way to embeddables) to re-use attributes. As a solution, embeddables are not supported and all attributes are mapped directly into the class.

### Can't define unique constraints for child entities
For child entities with an own table, it is not possible to define unique constraints.

## SQL Alchemy

No known limitations

## Hibernate

No known limitations