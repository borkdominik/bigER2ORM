#!/bin/sh
set -eu

OUTDIR="/app/schema-diffs"

# For each .sql file, produce a .grouped.md sibling
for sql in "$OUTDIR"/*.sql; do
  [ -e "$sql" ] || continue
  md="${sql%.sql}.grouped.md"

  # No diffs? Write a tiny MD and continue
  if grep -q '^-- No differences$' "$sql"; then
    printf "_No differences._\n" > "$md"
    echo "Grouped: $md"
    continue
  fi

  # Use Node to parse and group the SQL by table name
  node - "$sql" "$md" <<'NODE'
const fs = require('fs');

const input = fs.readFileSync(process.argv[2], 'utf8');
const out = process.argv[3];

const stmts = input
  .split(/;\s*\n/g)
  .map(s => s.trim())
  .filter(s => s && !s.startsWith('-- No differences'));

const byTable = new Map();
const misc = [];

function add(table, stmt) {
  if (!byTable.has(table)) byTable.set(table, []);
  byTable.get(table).push(stmt);
}

for (const s of stmts) {
  const oneLine = s.replace(/\s+/g, ' ');
  let m;
  // CREATE / ALTER / DROP TABLE
  if ((m = oneLine.match(/\bCREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))
   || (m = oneLine.match(/\bALTER\s+TABLE\s+(?:ONLY\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))
   || (m = oneLine.match(/\bDROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))) {
    const schema = (m[1]||'').replace(/\.$/,'').replace(/"/g,'') || 'public';
    const table = `${schema}.${m[2].replace(/"/g,'')}`;
    add(table, s + ';');
    continue;
  }
  // CREATE INDEX ... ON schema.table (...)
  if ((m = oneLine.match(/\bCREATE\s+(?:UNIQUE\s+)?INDEX\b.*\bON\s+("?[\w$]+"?\.)?"?([\w$]+)"?/i))) {
    const schema = (m[1]||'').replace(/\.$/,'').replace(/"/g,'') || 'public';
    const table = `${schema}.${m[2].replace(/"/g,'')}`;
    add(table, s + ';');
    continue;
  }
  // ALTER INDEX ... (no ON) -> bucket as :indexes
  if (/\bALTER\s+INDEX\b/i.test(oneLine)) {
    add(':indexes', s + ';');
    continue;
  }
  // Types, functions, extensions, sequences, etc. -> misc
  misc.push(s + ';');
}

let md = '';
if (byTable.size === 0 && misc.length === 0) {
  md = '_No differences._\n';
} else {
  const tables = [...byTable.keys()].sort((a,b)=>a.localeCompare(b));
  for (const t of tables) {
    md += `## ${t}\n\n`;
    md += '```sql\n' + byTable.get(t).join('\n\n') + '\n```\n\n';
  }
  if (misc.length) {
    md += `## (other)\n\n`;
    md += '```sql\n' + misc.join('\n\n') + '\n```\n';
  }
}
fs.writeFileSync(out, md, 'utf8');
NODE

  echo "Grouped: $md"
done

echo "Grouping complete."
