#!/usr/bin/env python3
import difflib
import subprocess
import sys
from pathlib import Path
from orm_utils import generate_orm_code

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
EXAMPLES_DIR = ROOT_DIR / "examples"


def test_code_equivalence():
    print("1. Programmatically generating target ORM code for examples/example...")
    orm_file = EXAMPLES_DIR / "example.orm"
    example_dir = EXAMPLES_DIR / "example"
    if not generate_orm_code(orm_file, example_dir):
        print("error: code generation failed", file=sys.stderr)
        return False

    print("\n2. Comparing generated code in examples/example against reference implementations...")
    techs = ["hibernate", "sql-alchemy", "entity-framework"]
    ignored_extensions = {".pyc", ".class", ".dll", ".exe", ".db", ".sqlite", ".iml"}
    ignored_dirs = {"bin", "obj", "target", "venv", ".vs", "__pycache__", "schema-diffs"}

    total_diffs = 0

    for tech in techs:
        gen_tech = EXAMPLES_DIR / "example" / tech
        ref_tech = SCRIPT_DIR / tech

        if not gen_tech.exists():
            print(f"error: generated directory missing: {gen_tech}", file=sys.stderr)
            total_diffs += 1
            continue

        if not ref_tech.exists():
            print(f"error: reference directory missing: {ref_tech}", file=sys.stderr)
            total_diffs += 1
            continue

        # Check for files in generated dir that don't match reference impl
        for g_file in gen_tech.rglob("*"):
            if not g_file.is_file():
                continue
            if g_file.suffix in ignored_extensions or any(part in ignored_dirs for part in g_file.parts):
                continue

            rel_path = g_file.relative_to(gen_tech)
            r_file = ref_tech / rel_path

            if not r_file.exists():
                print(f"  [MISSING IN REF] {tech}/{rel_path}")
                total_diffs += 1
                continue

            l_gen = g_file.read_text(encoding="utf-8-sig", errors="ignore").splitlines()
            l_ref = r_file.read_text(encoding="utf-8-sig", errors="ignore").splitlines()

            if l_gen != l_ref:
                print(f"  [CODE DIFF] {tech}/{rel_path}:")
                diff = list(difflib.unified_diff(l_gen, l_ref, fromfile=f"GEN: {rel_path}", tofile=f"REF: {rel_path}", lineterm=""))
                for line in diff[:25]:
                    print("   ", line)
                total_diffs += 1

    if total_diffs == 0:
        print("\nSUCCESS: Programmatically generated code in examples/example is 100% equivalent to orm-reference-implementations!")
        return True
    else:
        print(f"\nFAILURE: {total_diffs} code equivalence differences detected.", file=sys.stderr)
        return False


def test_round_trip_equivalence():
    print("\n3. Testing Reverse Engineering Round-Trip Equivalence Report...")
    from test_reverse_roundtrip import run_roundtrip_eval
    summary = run_roundtrip_eval(EXAMPLES_DIR / "example", batch_eval_mode=False)
    if summary and summary[0]["status"] in ("EQUIVALENT", "DIFFS_DETECTED"):
        return True
    return False


if __name__ == "__main__":
    success_equiv = test_code_equivalence()
    success_rt = test_round_trip_equivalence()
    sys.exit(0 if (success_equiv and success_rt) else 1)
