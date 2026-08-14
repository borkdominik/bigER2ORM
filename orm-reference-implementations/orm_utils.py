#!/usr/bin/env python3
import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
LANG_SERVER_DIR = ROOT_DIR / "language-server"
GRADLEW = LANG_SERVER_DIR / ("gradlew.bat" if sys.platform == "win32" else "gradlew")


def run_gradle(task: str, project_props: dict) -> bool:
    if not GRADLEW.exists():
        print(f"error: gradlew not found at {GRADLEW}", file=sys.stderr)
        return False

    cmd = [str(GRADLEW), "-p", str(LANG_SERVER_DIR), task]
    for key, val in project_props.items():
        cmd.append(f"-P{key}={val}")

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"error executing {task}:\n{res.stderr}\n{res.stdout}", file=sys.stderr)
        return False
    return True


def generate_orm_code(orm_file: Path, output_dir: Path, language: str = None) -> bool:
    props = {
        "ormFile": orm_file.resolve(),
        "outputDir": output_dir.resolve()
    }
    if language:
        props["language"] = language
    return run_gradle(":org.big.orm.ide:generateOrmCode", props)


def reverse_orm_code(input_dir: Path, output_file: Path, model_name: str) -> bool:
    props = {
        "inputDir": input_dir.resolve(),
        "outputFile": output_file.resolve(),
        "modelName": model_name
    }
    return run_gradle(":org.big.orm.ide:reverseOrmCode", props)


def normalize_line(line: str) -> str:
    l = line.strip()
    if l.startswith("orm_model "):
        return "orm_model _"
    l = re.sub(r'^(OneToOne|ManyToOne|ManyToMany)\s+relationship\s+(unidirectional\s+)?\w+', r'\1 relationship \2_', l)
    return re.sub(r'\s*=\s*', '=', l)


def sort_orm_file(input_file: Path, output_file: Path):
    text = input_file.read_text(encoding="utf-8-sig", errors="ignore")
    raw_lines = [l.strip() for l in text.splitlines() if l.strip()]

    blocks = []
    current_annos = []
    current_header = None
    current_body = []
    in_block = False

    for line in raw_lines:
        if line.startswith("orm_model "):
            continue
        if line.startswith("@(") and not in_block:
            current_annos.append(line)
            continue
        if "{" in line and not in_block:
            in_block = True
            current_header = "\n".join(current_annos + [line])
            current_body = []
            current_annos = []
            continue
        if line == "}" and in_block:
            in_block = False
            body_units = []
            unit_annos = []
            for bl in current_body:
                if bl.startswith("@("):
                    unit_annos.append(bl)
                else:
                    body_units.append("\n".join(unit_annos + [bl]))
                    unit_annos = []
            body_units.extend(unit_annos)
            body_units.sort()
            blocks.append({"header": current_header, "body": body_units})
            continue

        if in_block:
            current_body.append(line)
        else:
            blocks.append({"header": line, "body": []})

    def block_key(b):
        h = normalize_line(b["header"].splitlines()[-1])
        body_str = " | ".join(normalize_line(l) for l in b["body"])
        return f"{h} :: {body_str}"

    blocks.sort(key=block_key)

    lines = ["orm_model _", ""]
    for b in blocks:
        for hl in b["header"].splitlines():
            lines.append(normalize_line(hl))
        for unit in b["body"]:
            for ul in unit.splitlines():
                lines.append("    " + normalize_line(ul))
        lines.append("}" if b["header"].endswith("{") else "")
        lines.append("")

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
