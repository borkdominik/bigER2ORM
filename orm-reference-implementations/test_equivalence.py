#!/usr/bin/env python3
import difflib
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
EXAMPLES_DIR = ROOT_DIR / "examples"


def test_code_equivalence():
    print("1. Programmatically generating target ORM code for examples/example...")
    cmd = [
        sys.executable,
        str(SCRIPT_DIR / "run_eval.py"),
        str(EXAMPLES_DIR / "example"),
        "--generate"
    ]
    res = subprocess.run(cmd)
    if res.returncode != 0:
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
    print("\n3. Testing Reverse Engineering Round-Trip Equivalence...")
    gradlew = ROOT_DIR / "language-server" / ("gradlew.bat" if sys.platform == "win32" else "gradlew")
    if not gradlew.exists():
        print(f"error: gradlew not found at {gradlew}", file=sys.stderr)
        return False

    java_src = EXAMPLES_DIR / "example" / "hibernate" / "src" / "main" / "java"
    orig_orm = EXAMPLES_DIR / "example.orm"
    reversed_orm = EXAMPLES_DIR / "example" / "example_reversed.orm"

    print("  a. Reverse engineering Hibernate Java code -> example_reversed.orm...")
    rev_cmd = [
        str(gradlew),
        "-p", str(ROOT_DIR / "language-server"),
        ":org.big.orm.ide:reverseOrmCode",
        f"-PinputDir={java_src.resolve()}",
        f"-PoutputFile={reversed_orm.resolve()}",
        "-PmodelName=university"
    ]
    res = subprocess.run(rev_cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"error during reverse engineering:\n{res.stderr}\n{res.stdout}", file=sys.stderr)
        return False

    print("  b. Comparing original example.orm vs reverse-engineered example_reversed.orm...")
    import re

    def normalize_line(line):
        l = line.strip()
        # 1. Normalize arbitrary relationship block identifiers (e.g. RecognizedCertificateOriginalCertificate vs RecognizedCertificateCertificate)
        l = re.sub(r'^(OneToOne|ManyToOne|ManyToMany)\s+relationship\s+(unidirectional\s+)?\w+', r'\1 relationship \2_', l)
        return l

    l_orig = [normalize_line(l) for l in orig_orm.read_text(encoding="utf-8-sig", errors="ignore").splitlines() if l.strip()]
    l_rev = [normalize_line(l) for l in reversed_orm.read_text(encoding="utf-8-sig", errors="ignore").splitlines() if l.strip()]

    # 2. Account for attribute declaration ordering within blocks by comparing sorted non-empty lines
    s_orig = sorted(l_orig)
    s_rev = sorted(l_rev)

    if s_orig != s_rev:
        print("  [ORM MODEL DIFF] Differences found between example.orm and example_reversed.orm:")
        diff = list(difflib.unified_diff(l_orig, l_rev, fromfile="ORIGINAL example.orm", tofile="REVERSED example_reversed.orm", lineterm=""))
        for line in diff[:25]:
            print("   ", line)
        print(f"\nFAILURE: .orm model equivalence differences detected.", file=sys.stderr)
        return False

    print("\nSUCCESS: Reverse-engineered .orm model is 100% equivalent to original example.orm!")
    return True


if __name__ == "__main__":
    success_equiv = test_code_equivalence()
    success_rt = test_round_trip_equivalence()
    sys.exit(0 if (success_equiv and success_rt) else 1)
