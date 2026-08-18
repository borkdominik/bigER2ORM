#!/usr/bin/env python3
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Optional

RULES = [
    (r'\bvalidate\s+constraint\b', 'MIGRA-VALIDATE', 'Migra constraint validation artefact'),
    (r'\b(?:DROP|ADD)\s+CONSTRAINT\s+"?(?:PK_\w+|\w+_pkey)"?|\b(?:CREATE\s+UNIQUE\s+INDEX|DROP\s+INDEX(?:\s+IF\s+EXISTS)?)\s+"?(?:[\w$]+"?\.)?"?(?:PK_\w+|\w+_pkey)"?', 'PK-NAMING', 'Primary key constraint / index naming (EF Core vs standard)'),
    (r'\b(?:ADD|DROP)\s+CONSTRAINT\b.*\bFOREIGN\s+KEY\b|\bDROP\s+CONSTRAINT\s+"?fk_\w+"?', 'FK-CONSTRAINTS', 'Foreign key constraints & referential actions'),
    (r'\b(?:ADD|DROP)\s+CONSTRAINT\s+"?\w+_key"?|\b(?:ADD|DROP)\s+CONSTRAINT\b.*\bUNIQUE\b|\b(?:CREATE|DROP)\s+(?:UNIQUE\s+)?INDEX(?:\s+IF\s+EXISTS)?\s+"?(?:[\w$]+"?\.)?"?\w+_key"?|\bCREATE\s+UNIQUE\s+INDEX\b', 'UNIQUE-CONSTRAINTS', 'Unique constraints & indexes (1:1 associations)'),
    (r'\bCHECK\s*\(', 'CHECK-CONSTRAINTS', 'Check constraints'),
    (r'\bALTER\s+TABLE\b.*\bDROP\s+COLUMN\b', 'COLUMNS-DROPPED', 'Dropped columns (naming adaptations / model differences)'),
    (r'\bALTER\s+TABLE\b.*\bADD\s+COLUMN\b', 'COLUMNS-ADDED', 'Added columns (naming adaptations / model differences)'),
    (r'\bALTER\s+TABLE\b.*\bALTER\s+COLUMN\b', 'COLUMNS-ALTERED', 'Altered columns (data types, defaults, nullability)'),
    (r'\b(?:create|alter)\s+sequence\b|\bset\s+default\s+nextval\b|\b(?:drop|add)\s+identity\b', 'SEQUENCES-IDENTITY', 'Sequences vs identity columns'),
    (r'\bcreate\s+type\b.*\bas\s+enum\b|\bcreate\s+domain\b', 'ENUMS-DOMAINS', 'Custom enum types & domains'),
    (r'\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:FUNCTION|VIEW|TRIGGER)\b|\bCREATE\s+TABLE\b.*\binherits\b|^\s*CREATE\s+INDEX\b|\bset\s+check_function_bodies\b|\$function\$|\bLANGUAGE\s+plpgsql\b|\b(?:SELECT|RETURN|DECLARE|BEGIN|PERFORM|EXECUTE|RAISE|RECORD|END\s+(?:IF|LOOP)|CREATE\s+TEMPORARY\s+TABLE)\b|:=|\bv_out\b|\btmpSQL\b|\blast_month_', 'DB-OBJECTS', 'Database-level functional objects (triggers, functions, views)'),
    (r'\bCREATE\s+TABLE\b', 'TABLES-CREATED', 'Created tables'),
    (r'\bDROP\s+TABLE\b', 'TABLES-DROPPED', 'Dropped tables'),
]

ORDER = [
    'PK-NAMING', 'FK-CONSTRAINTS', 'UNIQUE-CONSTRAINTS', 'CHECK-CONSTRAINTS',
    'COLUMNS-DROPPED', 'COLUMNS-ADDED', 'COLUMNS-ALTERED',
    'SEQUENCES-IDENTITY', 'ENUMS-DOMAINS', 'DB-OBJECTS',
    'TABLES-CREATED', 'TABLES-DROPPED',
    'UNIDENTIFIED', 'MIGRA-VALIDATE'
]


def extract_table(stmt: str) -> Optional[str]:
    m = re.search(r'\b(?:ALTER\s+TABLE(?:\s+ONLY)?|CREATE(?:\s+UNIQUE)?\s+INDEX\s+[\w$]+\s+ON|CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|DROP\s+TABLE(?:\s+IF\s+EXISTS)?)\s+("?[\w$]+"?\.)?("?[\w$]+"?)', stmt, re.I)
    if not m:
        return None
    schema = (m.group(1) or '').rstrip('.').replace('"', '') or 'public'
    table = m.group(2).replace('"', '')
    return f"{schema}.{table}"


def classify(stmt: str) -> tuple[str, str]:
    one = stmt.replace('\n', ' ')
    for pattern, cat, desc in RULES:
        if re.search(pattern, one, re.I):
            return cat, desc
    return 'UNIDENTIFIED', 'Statement not matched by generic DDL patterns'


def render_group(category: str, desc: str, stmts: list[str]) -> str:
    block = '\n\n'.join(s + ';' for s in stmts)
    if category == 'UNIDENTIFIED':
        return '\n\n'.join(f"> [!WARNING]\n> **UNIDENTIFIED DIFFERENCE**\n>\n> ```sql\n" + '\n'.join(f"> {l}" for l in (s + ';').splitlines()) + "\n> ```" for s in stmts)
    if category == 'MIGRA-VALIDATE':
        return f"<details>\n<summary>{category}: {desc}</summary>\n\n```sql\n{block}\n```\n</details>"
    return f"### {category}: {desc}\n\n```sql\n{block}\n```"


def classify_schema_diffs(diff_dir: Path) -> None:
    for sql_path in sorted(diff_dir.glob('*.sql')):
        md_path = sql_path.with_suffix('').with_suffix('.classified.md')
        text = sql_path.read_text(encoding='utf-8', errors='replace').strip()

        if not text or re.search(r'^--\s*No differences', text, re.M):
            md_path.write_text('_No differences._\n', encoding='utf-8')
            print(f'  [classify] {sql_path.name} -> no differences')
            continue

        raw = [s.strip() for s in re.split(r';\s*\n', text) if s.strip() and not s.strip().startswith('-- No differences')]
        annotated = [(s, extract_table(s), *classify(s)) for s in raw]

        table_map = defaultdict(list)
        misc = []
        for s, table, cat, desc in annotated:
            (table_map[table] if table else misc).append((s, cat, desc))

        if sum(len(v) for v in table_map.values()) + len(misc) != len(annotated):
            raise RuntimeError(f"Statement count mismatch in {sql_path.name}")

        parts = []
        for table in sorted(table_map.keys()):
            parts.append(f"## {table}\n")
            buckets = defaultdict(list)
            for s, cat, desc in table_map[table]:
                buckets[cat].append((s, desc))
            for cat in ORDER:
                if cat in buckets:
                    parts.append(render_group(cat, buckets[cat][0][1], [s for s, _ in buckets[cat]]))
            parts.append("")

        if misc:
            parts.append("## (other)\n")
            buckets = defaultdict(list)
            for s, cat, desc in misc:
                buckets[cat].append((s, desc))
            for cat in ORDER:
                if cat in buckets:
                    parts.append(render_group(cat, buckets[cat][0][1], [s for s, _ in buckets[cat]]))
            parts.append("")

        md_path.write_text('\n'.join(parts), encoding='utf-8')
        unid = sum(1 for _, _, cat, _ in annotated if cat == 'UNIDENTIFIED')
        flag = f'  WARNING: {unid} UNIDENTIFIED' if unid else ''
        print(f'  [classify] {sql_path.name} -> {len(annotated)} stmts{flag}')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <schema-diffs-dir>", file=sys.stderr)
        sys.exit(1)
    classify_schema_diffs(Path(sys.argv[1]))
