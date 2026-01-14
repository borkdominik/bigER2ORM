<!-- LOGO -->
<p align="center">
    <img src="https://raw.githubusercontent.com/borkdominik/bigER2ORM/refs/heads/main/extension/media/logo.png" alt="Logo" width="150" height="150" style="border-radius: 25px" />
</p>

<!-- TITLE -->
<h1 align="center">bigORM Modeling Tool - VS Code Extension</h1>

<!-- BADGES -->
<div align="center">
    <a href="https://github.com/borkdominik/bigER2ORM">
        <img alt="GitHub Build" src="https://img.shields.io/github/actions/workflow/status/borkdominik/bigER2ORM/buildandrelease.yml?branch=main" height="20"/>
    </a>
    <a href="https://marketplace.visualstudio.com/items?itemName=BIGModelingTools.bigorm">
        <img alt="Visual Studio Marketplace Installs" src="https://img.shields.io/visual-studio-marketplace/i/BIGModelingTools.bigorm" height="20"/>
    </a>
    <a href="https://marketplace.visualstudio.com/items?itemName=BIGModelingTools.bigorm">
        <img alt="Visual Studio Marketplace Version" src="https://img.shields.io/visual-studio-marketplace/v/BIGModelingTools.bigorm" height="20"/>
    </a>
    <a href="https://marketplace.visualstudio.com/items?itemName=BIGModelingTools.bigorm">
        <img alt="Visual Studio Marketplace Last Updated" src="https://img.shields.io/visual-studio-marketplace/last-updated/BIGModelingTools.bigorm?color=blue" height="20"/>
    </a>
    <a href="https://github.com/borkdominik/bigER2ORM">
        <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/borkdominik/bigER2ORM?color=lightgrey" height="20"/>
    </a>
    <a href="https://github.com/borkdominik/bigER2ORM">
        <img alt="GitHub Stars" src="https://img.shields.io/github/stars/borkdominik/bigER2ORM?style=social" height="20">
    </a>
</div>

**bigORM** is a tool used to model ORM structures in a generic way and later on generate framework specific ORM code for some of the most popular ORM frameworks, with the code resulting in an equal database structure for all supported frameworks. Currently supported frameworks are Hibernate for Java, SQLalchemy for Python and the .NET Entity Framework.

<!-- DEMO -->
<p align="center">
  <img src="https://raw.githubusercontent.com/borkdominik/bigER2ORM/refs/heads/main/extension/media/example.gif" alt="Demo" width="800" />
</p>

<!-- FEATURES -->
**Main features:**

- 📝 **Textual Language** for the specification of ORM models in the textual editor. Assistive *validation* and *rich-text editing* support, enabled with the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/), allows to quickly get familiar with the available language constructs.
- 📊 **Diagram View** that is fully synchronized with the textual model and automatically updates on changes. Also offers an interactive toolbar with *layout mechanisms*.
- 🖨️ **Code Generation** to *generate ORM code* out of the specified ORM models and integrate with existing databases. Currently support for *Hiberate*, *SQLAlchemy* and *Entity Framework*.
- ⏪ **Reverse Engineering (EXPERIMENTAL)** to *generate ORM Models* out of existing Hibernate ORM code.

# 📖 Table of Contents <!-- omit from toc -->

- [1. About the Project](#1-about-the-project)
- [2. Prerequisites](#2-prerequisites)
- [3. Installation](#3-installation)
- [4. User Documentation](#4-user-documentation)
  - [4.1. ORM Modeling](#41-orm-modeling)
    - [4.1.1. Data Elements](#411-data-elements)
      - [4.1.1.1. Embeddables](#4111-embeddables)
      - [4.1.1.2. Embeddables](#4112-embeddables)
      - [4.1.1.3. Enums](#4113-enums)
      - [4.1.1.4. Entities](#4114-entities)
        - [4.1.1.4.1. Join Entities](#41141-join-entities)
      - [4.1.1.5. Mapped Classes](#4115-mapped-classes)
    - [4.1.2. Relationships](#412-relationships)
    - [4.1.3. Data types](#413-data-types)
    - [4.1.4. Type modifiers](#414-type-modifiers)
  - [4.2. Model Visualization](#42-model-visualization)
  - [4.3. Code Generation](#43-code-generation)
    - [4.3.1. Batch Code generation](#431-batch-code-generation)
  - [4.4. ORM Reverse engineering (!EXPERIMENTAL!)](#44-orm-reverse-engineering-experimental)



# 1. About the Project

Object-relational mapping (ORM) is commonly used to bridge the gap between table-based persistency and object-oriented programming. Usually the mappings for ORM are directly defined in the codebase, requiring a defined technology stack from the beginning and reducing flexibility during the datastructure design process.

The **bigORM** tool aims to provide an open-source and modern solution for modeling data-structures for ORM, independently of the programming language, by making use of the [Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol/). The protocol is used for communicating textual language features to the VS Code client and is further extended to also support graphical editing, making it one of the first *hybrid modeling tools* based on the LSP.

# 2. Prerequisites

- [Java](http://jdk.java.net/) JDK 17 (tested: [17.0.2](http://jdk.java.net/archive/))
- [VS Code](https://code.visualstudio.com/) v1.90 or above

# 3. Installation

**bigORM** can be installed directly from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=BIGModelingTools.bigorm)

# 4. User Documentation

The following section describes the features the framework supports.

## 4.1. ORM Modeling

The main capability of **bigORM** is the modeling of the class structure that should be defined by ORM. **bigORM** is automatically loaded for VS Code for all files ending with ``.orm``

Every model starts with the definition of the model name, defined as follows:

```
orm_model <model name>
```

Afterwards the different model elements can be defined, which can be devided into data elements and relationships, which are described in dedicated sub-sections. Additionally this section also explains supported data types and type modifiers.

An example of an bigORM model using all currently supported features can be found on [GitHub](https://github.com/borkdominik/bigER2ORM/blob/main/examples/example.orm).

### 4.1.1. Data Elements

Data elements are elements that represent data containers, for the targeted ORM frameworks they are mainly translated to classes.

There are three types of data elements:

#### 4.1.1.1. Embeddables

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

#### 4.1.1.2. Embeddables

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

Embeddables can be used as ``keys``, allowing to create composite primary keys.

#### 4.1.1.3. Enums

Enums are a custom datatype to represent a limited amount of fixed constants. They can be created as follows:

```
enum Status {
    VALID
    INVALID
}
```

**Note:** **bigORM** always maps enums to strings within the database. Custom types, which some databases might support, are not supported.

#### 4.1.1.4. Entities

An Entity represents an object that is meant to be saved within the database. They need a key, additionally they support inheritance from other entities.

See the following for an example on how entities could be defined:

```
@(Inheritance.JoinedTable)
entity Certificate {
    id UUID key
    grade Integer
    enum status Status
    examAddress Address
}

entity RecognizedCertificate extends Certificate {
}
```

Notice how the annotation on the parent class defines how the child classes will inherit the class, especially how the later selected framework should translate this into the database. Options here include:

- ``Inheritance.JoinedTable`` : Child classes will contain a foreign key to their parent object. Default inheritance strategy, if not explicitly defined.
- ``Inheritance.TablePerClass`` : Every class will have a dedicated table covering all attributes
- ``Inheritance.SingleTable`` : All objects are in the same table, having a dedicated column to differentiat which kind of type the object has

##### 4.1.1.4.1. Join Entities

Join entities represent a special kind of entity within **bigORM**. Instead of defining their own primary key, they are defined to join two other entities and will get a composite primary key from the joined entities. The join entity automatically creates additional ``ManyToOne`` relationships from itself to the joined entities.

This is used to represent ``ManyToMany`` relationships, with additional attributes. An example is provided in the following:

```
entity StudentStudyProgram joins (Student["studies"], StudyProgram["students"]) {
    finished Boolean
}
```

**Note:** Join entities do not support extending other classes or defining additional primary keys.

#### 4.1.1.5. Mapped Classes

In addition to entities and embeddables, **bigORM** also supports Mapped Classes, which can be used to define recurring patterns in entities, like standardized UUID structures. An example is provided in the following:

```
mapped_class NamedElement{
    id UUID key
    name String
}

@(Inheritance.TablePerClass)
entity Person extends NamedElement{
    address Address
}

@(Inheritance.SingleTable)
entity Course extends NamedElement {
}
```

### 4.1.2. Relationships

Defined entities can be connected using relationships, which can be defined as follows:

```
ManyToMany relationship StudentStudyProgram {
    source Student["studies"]
    target StudyProgram["students"]
}
```

The first keyword describes the relationship type. Options are:

- ``ManyToMany``
- ``ManyToOne``
- ``OneToOne``

Afterwards the ``relationship`` keyword defines the object actually as an relationship, which is followed by the name of the relationship. Additionally is is possible to include the ``unidirectional`` keyword between the ``relationship`` keyword and the name, to mark the relationship as unidirection, therefore only having the relationship available from within the source.

Afterwards the ``source`` and ``target`` have to be defined, by describing the Entities that the relationship is related to, in addition to the property under which the relationship element should be accessable from within the object. For the source it is possible to define whether a connected object is ``required``.

**Note:** **bigORM** does not support ``OneToMany`` relationships, due to them requiring a dedicated table, which is often considered bad practice.

**Note:** **bigORM** does not support additional attributes within relationships. Storing additional attributes always requires a dedicated table, for ``OneToOne`` or ``ManyToOne`` relationships, it is considered best practice to include the additional property in one of the existing entities, to not need an additional table. For ``ManyToMany`` all supported ORM systems actually create an additional entity that joins both entities via two ``ManyToOne`` relationships. To better reflect this, we've defined the concept of ``Join Entities``, described in section [4.1.1.4.1. Join Entities](#41141-join-entities).

### 4.1.3. Data types

Supported datatypes are:

- ``String``
- ``Integer``
- ``Boolean``
- ``UUID``

### 4.1.4. Type modifiers

Currently supported modifiers are:

- ``key`` : describes the property as a primary key for the object
- ``required`` : describes the property as required within the database
- ``none`` : default for not adapting the property

## 4.2. Model Visualization

When opening an ``.orm`` file, the diagram icon in the top right allows to display the model in a diagram to be able to inspect the overall structure.

## 4.3. Code Generation

Same as with the diagram view, the toolbar also allows the export to a specific framework, by using the ``Generate Code from Model`` command. This is a guided process, asking for user inputs to be able to achieve the code generation

### 4.3.1. Batch Code generation

Using the command ``bigORM: Reverse all files in folder model for each language`` it is possible to create all ORM implementation for all languages for all ``.orm`` files inside a folder. This is especially helpful when using the evaluation framework. 

## 4.4. ORM Reverse engineering (!EXPERIMENTAL!)

As an experimental feature, **bigORM** also supports to reverse engineer Hibernate models to ``.orm`` models, this is also triggered via the **bigORM** toolbar and is achieved by a guided process.
