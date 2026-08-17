#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from orm_utils import generate_orm_code, reverse_orm_code, sort_orm_file

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
EXAMPLES_DIR = ROOT_DIR / "examples"


def run_single_roundtrip_report(orm_file: Path, project_dir: Path) -> dict:
    model_name = orm_file.stem
    print(f"\n--- Round-Trip Check: {orm_file.name} ---")

    sorted_orig = project_dir / f"{model_name}_sorted.orm"
    reversed_orm = project_dir / f"{model_name}_reversed.orm"
    sorted_rev = project_dir / f"{model_name}_reversed_sorted.orm"

    sort_orm_file(orm_file, sorted_orig)

    print("1. Generating Java ORM code...")
    if not generate_orm_code(orm_file, project_dir, language="Hibernate"):
        return {"model": orm_file.name, "status": "GEN_ERROR"}

    print(f"2. Reverse engineering Java source -> {reversed_orm.name}...")
    java_src = project_dir / "hibernate" / "src" / "main" / "java"
    if not reverse_orm_code(java_src, reversed_orm, model_name):
        return {"model": orm_file.name, "status": "REV_ERROR"}

    sort_orm_file(reversed_orm, sorted_rev)

    print(f"3. Comparing {sorted_orig.name} vs {sorted_rev.name}...")
    l_orig = sorted_orig.read_text(encoding="utf-8").splitlines()
    l_rev = sorted_rev.read_text(encoding="utf-8").splitlines()

    if l_orig == l_rev:
        print(f"OK: 100% equivalent ({orm_file.name})")
        return {"model": orm_file.name, "status": "EQUIVALENT"}
    else:
        print(f"NOT OK: diff detected ({orm_file.name})")
        return {"model": orm_file.name, "status": "DIFFS_DETECTED"}


def run_roundtrip_eval(input_folder: Path, batch_eval_mode: bool = False) -> list:
    input_path = input_folder.resolve()
    targets = []

    if batch_eval_mode:
        for orm in sorted(input_path.glob("*.orm")):
            proj_dir = input_path / orm.stem
            proj_dir.mkdir(parents=True, exist_ok=True)
            targets.append((orm, proj_dir))
    else:
        if input_path.is_dir():
            orm = input_path.parent / f"{input_path.name}.orm"
            if not orm.exists():
                orm_in = list(input_path.glob("*.orm"))
                orm = orm_in[0] if orm_in else orm
            targets.append((orm, input_path))

    if not targets:
        print(f"error: no valid .orm models found in {input_path}", file=sys.stderr)
        return []

    print(f"Evaluating {len(targets)} model(s)...")
    summary = [run_single_roundtrip_report(orm_file, proj_dir) for orm_file, proj_dir in targets]

    diff_models = [r["model"] for r in summary if r["status"] != "EQUIVALENT"]

    print("\n--- Summary ---")
    if not diff_models:
        print(f"All OK: 100% equivalent across all {len(summary)} model(s)")
    else:
        print(f"Diffs detected in: {', '.join(diff_models)}")

    return summary


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Round-trip reverse engineering evaluation.")
    parser.add_argument("input_folder", type=Path, nargs="?", default=EXAMPLES_DIR / "example",
                        help="Input directory or project folder (defaults to examples/example)")
    parser.add_argument("--batch-eval-mode", action="store_true",
                        help="Scan all *.orm files in input_folder")
    args = parser.parse_args()

    run_roundtrip_eval(args.input_folder, args.batch_eval_mode)
    sys.exit(0)
