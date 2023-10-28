TODO: Readme needs improvement, this is currently only focused on a rough feature description 

bigORM is a tool used to model ORM structures in a generic way and later on generate framework specific ORM code for some of the most popular ORM frameworks, with the code resulting in an equal database structure for all supported frameworks. Currently supported frameworks are Hibernate for Java and SQLalchemy for Python, in the near future additionally the .NET Entity Framework is planned to be supported.

# Features

The following section describes the features the framework supports.

## ORM Modeling

The main capability of bigORM is the modeling of the class structure that should be defined by ORM. bigORM is automatically loaded for VS Code for all files ending with ``.orm``

Every model starts with the definition of the model name, defined as follows:

```orm_model <model name>```

Afterwards the different model elements can be defined, which can be devided into data elements and relationships between those elements. Additionally this section also explains supported data types and type modifiers.

### Data Elements
Data elements are elements that represent data containers, for the Frameworks they are mainly translated to classes.

There are two types of data elements:

#### Embeddables

Embeddables represent containers to display repeated standardized data structures.

An example would be as follows:

```
embeddable Address {
    street String
    city String
    postCode Integer
    country String
}
```

Embeddables do not support type modifiers.

#### Entities

An Entity represents an object that is meant to be saved within the database. They need a key, additionally they support inheritance from other entities.

See the following for an example on how entities could be defined:

```
@(Inheritance.JoinedTable)
entity Certificate {
    id UUID key
    grade Integer
}

entity RecognizedCertificate extends Certificate {
}
```

Notice how the annotation on the parent class defines how the child classes will inherit the class, especially how the later selected framework should translate this into the database. Options here include:

* Inheritance.JoinedTable : Child classes will contain a foreign key to their parent object
* Inheritance.TablePerClass : Every class will have a dedicated table covering all attributes
* Inheritance.SingleTable : All objects are in the same table, having a dedicated column to differentiat which kind of type the object has


### Relationships

Entities defined can than be included in relationships, which can look like as follows:

```
ManyToMany relationship StudentStudyProgram {
    source Student["studies"]
    target StudyProgram["students"]
    finished Boolean
}
```

The first keyword describes the relationship type, options are:
* ManyToMany
* ManyToOne
* OneToMany
* OneToOne

Afterwards the ``relationship`` keyword defines the object actually as an relationship, which is followed by the name of the relationship. Additionally is is possible to include the ``unidirectional`` keyword between the ``relationship`` keyword and the name, to mark the relationship as unidirection, therefore only having the relationship available from within the source.

Afterwards the source and target have to be defined, by describing the Entities that the relationship is related to, in addition to the property under which the relationship element should be accessable from within the object.

Finally it is possible to include additional properties for the relationship, if this is needed.

### Data types
Supported datatypes are: 
* String
* Integer
* Boolean
* UUID

### Type modifiers
Currently supported modifiers are:

* key : describes the property as a primary key for the object
* required : describes the property as required within the database
* none : default for not adapting the property 

## Model Visualization

When opening an ``.orm`` file, the diagram icon in the top right allows to display the model in a diagram to be able to inspect the overall structure.

## Code Generation

Same as with the diagram view, the toolbar also allows the export to a specific framework, by using the "Generate Code from Model" command. This is a guided process, asking for a few user inputs to be able to achieve the code generation

## ORM Reverse engineering (!EXPERIMENTAL!)

As an experimental feature, bigORM also supports to reverse engineer Hibernate models to ``.orm`` models, this is also triggered via the orm toolbar and is achieved by a guided process.