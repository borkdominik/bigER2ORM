#!/bin/env python3
import argparse
import subprocess
import sys
import time
from pathlib import Path
from orm_utils import generate_orm_code

REQUIRED_TECH_DIRS = ("hibernate", "entity-framework", "sql-alchemy")


def main():
    parser = argparse.ArgumentParser(description="DST Reference Eval: validate DST TU Wien model and run Docker Compose with DST reference DB initialization.")
    parser.add_argument("input_folder", nargs="?", type=Path, default=None,
                        help="Optional folder for DST project (defaults to examples/dst_tu_wien)")
    parser.add_argument("--generate", action="store_true",
                        help="Programmatically generate target ORM code from dst_tu_wien.orm before running evaluation")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    root_dir = script_dir.parent

    if args.input_folder:
        input_folder = args.input_folder.resolve()
    else:
        input_folder = (root_dir / "examples" / "dst_tu_wien").resolve()

    if not input_folder.is_dir():
        print(f"error: DST project folder not found at {input_folder}", file=sys.stderr)
        return 1

    compose_file_base = script_dir / "docker-compose.eval.yml"
    compose_file_dst = script_dir / "docker-compose.dst.yml"

    if not compose_file_base.exists():
        print(f"error: base compose file not found at {compose_file_base}", file=sys.stderr)
        return 1
    if not compose_file_dst.exists():
        print(f"error: dst compose override file not found at {compose_file_dst}", file=sys.stderr)
        return 1

    compose_args = ["-f", str(compose_file_base), "-f", str(compose_file_dst)]

    if args.generate:
        orm_file = root_dir / "examples" / "dst_tu_wien.orm"
        if not orm_file.exists():
            print(f"error: expected model file {orm_file} does not exist", file=sys.stderr)
            return 1
        print(f"Generating code for {orm_file.name} -> {input_folder}...")
        if not generate_orm_code(orm_file, input_folder):
            return 1

    for sub in REQUIRED_TECH_DIRS:
        if not (input_folder / sub).is_dir():
            print(f"error: missing required subfolder: {input_folder / sub}", file=sys.stderr)
            return 1

    print(f"Running DST Reference Evaluation for: {input_folder}")
    cmd_up = ["docker", "compose", "--project-directory", str(input_folder)] + compose_args + ["up", "-d"]
    if subprocess.call(cmd_up, cwd=str(input_folder)) != 0:
        print(f"error: failed docker compose up (cwd={input_folder})", file=sys.stderr)
        subprocess.call(["docker", "compose", "--project-directory", str(input_folder)] + compose_args + ["down", "-v"], cwd=str(input_folder))
        return 1

    cid = ""
    deadline = time.time() + 180
    while time.time() < deadline and not cid:
        out = subprocess.run(
            ["docker", "compose", "--project-directory", str(input_folder)] + compose_args + ["ps", "-q", "migra-runner"],
            cwd=str(input_folder),
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
        )
        cid = (out.stdout or "").strip()
        if cid:
            break
        time.sleep(2)

    if not cid:
        print("error: migra-runner did not start within 180s", file=sys.stderr)
        subprocess.call(["docker", "compose", "--project-directory", str(input_folder)] + compose_args + ["down", "-v"], cwd=str(input_folder))
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

    subprocess.call(["docker", "compose", "--project-directory", str(input_folder)] + compose_args + ["down", "-v"], cwd=str(input_folder))

    if exit_code == 0:
        diff_dir = input_folder / "schema-diffs"
        print(f"\nSUCCESS: DST project evaluation OK! Diff files saved in {diff_dir}")
        return 0
    else:
        print(f"\nERROR: DST project evaluation failed with exit code {exit_code}", file=sys.stderr)
        return exit_code


if __name__ == "__main__":
    sys.exit(main())
