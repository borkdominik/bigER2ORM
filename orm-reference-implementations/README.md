# Evaluation Framework

This folder contains the ``bigORM`` evaluation framework. It allows to compare the generated database code between all frameworks and generates an output result containing the differences.

## Prerequisits
* ``Docker`` must be installed and running (tested: ``28.5.1``)
* ``Python`` (tested: ``3.10``)
* ``Java JDK 17+`` (for programmatic code generation via Gradle)

## How to test manually and install

Not all docker images needed are created automatically during the automatic validation, but only on manual testing. For this, simply run from the ``orm-reference-implementations`` folder the following commands:

1. ```docker compose build --no-cache``` -> builds containers
2. ```docker compose up``` -> This compares the reference implementations
3. check the results in the automatically generated folder ```schema-diffs``` or using ``pgadmin`` running at http://localhost:5555/
4. ```docker compose down -v``` -> Removes all containers

## How to use for single projects

1. Programmatically generate target ORM code and run evaluation:
   ```bash
   python run_eval.py ..\examples\example\ --generate
   ```
   *(Alternatively, generate code manually via VS Code into ``entity-framework``, ``hibernate`` & ``sql-alchemy`` folders, and run ``python run_eval.py ..\examples\example\``)*
2. Check the results in ``schema-diffs`` inside the target folder (e.g. ``..\examples\example\schema-diffs``).

## How to use for batch evaluation

1. Programmatically generate target ORM code and run batch evaluation across all models:
   ```bash
   python run_eval.py ..\examples\ --batch-eval-mode --generate
   ```
   *(Alternatively, use the "batch code creation" command in the VS Code Extension, then run ``python run_eval.py ..\examples\ --batch-eval-mode``)*
2. Check the results in ``schema-diffs`` inside each subfolder within the target folder.

## How to run round-trip evaluation

1. *(Prerequisite)* Programmatically generate target ORM code beforehand so project files are ready:
   ```bash
   python run_eval.py ..\examples\ --batch-eval-mode --generate
   ```
2. Run round-trip reverse engineering evaluation for a single project model:
   ```bash
   python test_reverse_roundtrip.py ..\examples\example
   ```
3. Run batch round-trip reverse engineering evaluation across all models:
   ```bash
   python test_reverse_roundtrip.py ..\examples --batch-eval-mode
   ```
4. Check the printed summary report and compare the generated `<model_name>_sorted.orm` vs `<model_name>_reversed_sorted.orm` files in each project directory for structural equivalence.

## Known Limitations of Evaluation Framework

* Certain small evaluations are different between using the manual tool in ``pgadmin`` for schema diff and the automated tool provided by ``migra``.
* **Attribute Name Collision Constraint**: Attribute or relationship names cannot match their enclosing entity name (case-insensitively). This is validated by the ``bigORM`` language server (`checkEntityNameDoesNotMatchAnyAttributeName`) to prevent target language identifier collisions (e.g. C# CS0542 where class members cannot share the name of their enclosing class).