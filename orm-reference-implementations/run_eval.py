#!/usr/bin/env python3
import argparse
import subprocess
import sys
import time
from pathlib import Path
from orm_utils import generate_orm_code

REQUIRED_TECH_DIRS = ("hibernate", "entity-framework", "sql-alchemy")


def main():
    parser = argparse.ArgumentParser(description="Eval: validate *.orm projects and run compose per project.")
    parser.add_argument("input_folder", type=Path, help="Folder containing *.orm and matching project folders")
    parser.add_argument("--batch-eval-mode", action="store_true",
                        help="Enable batch eval mode")
    parser.add_argument("--generate", action="store_true",
                        help="Programmatically generate target ORM code from .orm files before running evaluation")
    args = parser.parse_args()

    input_folder = args.input_folder.resolve()
    if args.generate:
        input_folder.mkdir(parents=True, exist_ok=True)
    if not input_folder.is_dir():
        print(f"error: {input_folder} is not a directory", file=sys.stderr)
        return 1

    # Compose file lives NEXT TO THIS SCRIPT, not in each project dir.
    script_dir = Path(__file__).resolve().parent
    compose_file = script_dir / "docker-compose.eval.yml"
    if not compose_file.exists():
        print(f"error: compose file not found at {compose_file}", file=sys.stderr)
        return 1

    # If --generate is specified, programmatically generate ORM code
    if args.generate:
        print("Programmatically generating ORM code from .orm files...")
        targets_to_generate = []
        if args.batch_eval_mode:
            orm_files = sorted(input_folder.glob("*.orm"))
            if not orm_files:
                print(f"error: no .orm files found in {input_folder}", file=sys.stderr)
                return 1
            for orm in orm_files:
                target_dir = input_folder / orm.stem
                target_dir.mkdir(parents=True, exist_ok=True)
                targets_to_generate.append((orm, target_dir))
        else:
            orm = input_folder.parent / f"{input_folder.name}.orm"
            if not orm.exists():
                print(f"error: expected model file {orm} does not exist", file=sys.stderr)
                return 1
            targets_to_generate.append((orm, input_folder))

        for orm_file, target_dir in targets_to_generate:
            print(f"Generating code for {orm_file.name} -> {target_dir}...")
            if not generate_orm_code(orm_file, target_dir):
                return 1

    if args.batch_eval_mode:
    # 1) find *.orm
        orm_files = sorted(input_folder.glob("*.orm"))
        if not orm_files:
            print(f"error: no .orm files found in {input_folder}", file=sys.stderr)
            return 1

        # 2) match each *.orm with a project folder
        projects = []
        missing = []
        for orm in orm_files:
            d = input_folder / orm.stem
            (projects if d.is_dir() else missing).append(d)
        if missing:
            print("error: missing project folders for:", file=sys.stderr)
            for m in missing:
                print(f"  - {m}", file=sys.stderr)
            return 1
    else:
        projects = [input_folder]


    # 3) check subfolders
    missing_sub = []
    for proj in projects:
        for sub in REQUIRED_TECH_DIRS:
            if not (proj / sub).is_dir():
                missing_sub.append(proj / sub)
    if missing_sub:
        print("error: missing required subfolders:", file=sys.stderr)
        for m in missing_sub:
            print(f"  - {m}", file=sys.stderr)
        print("required per project:", ", ".join(REQUIRED_TECH_DIRS), file=sys.stderr)
        return 1

    # 4+5) run each project: up -d with the compose file next to the script, but CWD = project dir
    for proj in projects:
        cmd_up = ["docker", "compose", "--project-directory", str(proj), "-f", str(compose_file), "up", "-d"]
        if subprocess.call(cmd_up, cwd=str(proj)) != 0:
            print(f"error: failed: {' '.join(cmd_up)} (cwd={proj})", file=sys.stderr)
            subprocess.call(["docker", "compose", "--project-directory", str(proj), "-f", str(compose_file), "down", "-v"], cwd=str(proj))
            return 1

        cid = ""
        deadline = time.time() + 120
        while time.time() < deadline and not cid:
            out = subprocess.run(
               ["docker", "compose", "--project-directory", str(proj), "-f", str(compose_file), "ps", "-q", "migra-runner"],
                cwd=str(proj),
                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
            )
            cid = (out.stdout or "").strip()
            if cid:
                break
            time.sleep(2)
        if not cid:
            print("error: migra-runner did not start within 120s", file=sys.stderr)
            subprocess.call(["docker", "compose", "--project-directory", str(proj), "-f", str(compose_file), "down", "-v"], cwd=str(proj))
            return 1

        exit_code = 1
        while True:
            st = subprocess.run(
                ["docker", "inspect", "-f", "{{.State.Status}}", cid],
                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
            )
            status = (st.stdout or "").strip()
            if status in {"exited", "dead"}:
                ec = subprocess.run(
                    ["docker", "inspect", "-f", "{{.State.ExitCode}}", cid],
                    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
                )
                try:
                    exit_code = int((ec.stdout or "1").strip())
                except ValueError:
                    exit_code = 1
                break
            time.sleep(2)

        subprocess.call(["docker", "compose", "--project-directory", str(proj), "-f", str(compose_file), "down", "-v"], cwd=str(proj))

        if exit_code != 0:
            print(f"error: project {proj.name} failed (exit {exit_code})", file=sys.stderr)
            return exit_code

        print(f"project {proj.name} OK")

    print("all projects OK")
    return 0

if __name__ == "__main__":
    sys.exit(main())
