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

const tableData = new Map();
const misc = [];

function getEntry(table) {
  if (!tableData.has(table)) {
    tableData.set(table, {
      regularStmts: [],
      pkRenamingStmts: [],
      droppedPkConstraints: new Set(),
      droppedPkNames: new Set()
    });
  }
  return tableData.get(table);
}

const unassignedDropIndexes = [];

for (const s of stmts) {
  const oneLine = s.replace(/\s+/g, ' ');
  let m;

  // 1. ALTER TABLE ... DROP CONSTRAINT "PK_..."
  if ((m = oneLine.match(/\bALTER\s+TABLE\s+(?:ONLY\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?\s+DROP\s+CONSTRAINT\s+(?:IF\s+EXISTS\s+)?("?[\w$]+"?)/i))) {
    const schema = (m[1] || '').replace(/\.$/, '').replace(/"/g, '') || 'public';
    const tableName = m[2].replace(/"/g, '');
    const constraintName = m[3].replace(/"/g, '');
    const tableKey = `${schema}.${tableName}`;
    const entry = getEntry(tableKey);

    if (/^(?:PK_|pk_)/i.test(constraintName)) {
      entry.droppedPkConstraints.add(constraintName);
      entry.droppedPkNames.add(tableName.toLowerCase());
      entry.pkRenamingStmts.push(s + ';');
    } else {
      entry.regularStmts.push(s + ';');
    }
    continue;
  }

  // 2. ALTER TABLE ... ADD CONSTRAINT "..._pkey" PRIMARY KEY ...
  if ((m = oneLine.match(/\bALTER\s+TABLE\s+(?:ONLY\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?\s+ADD\s+CONSTRAINT\s+("?[\w$]+"?)\s+PRIMARY\s+KEY/i))) {
    const schema = (m[1] || '').replace(/\.$/, '').replace(/"/g, '') || 'public';
    const tableName = m[2].replace(/"/g, '');
    const constraintName = m[3].replace(/"/g, '');
    const tableKey = `${schema}.${tableName}`;
    const entry = getEntry(tableKey);

    if (/_pkey$/i.test(constraintName) || entry.droppedPkConstraints.size > 0) {
      entry.pkRenamingStmts.push(s + ';');
    } else {
      entry.regularStmts.push(s + ';');
    }
    continue;
  }

  // 3. CREATE UNIQUE INDEX ... ON schema.table
  if ((m = oneLine.match(/\bCREATE\s+(?:UNIQUE\s+)?INDEX\s+("?[\w$]+"?\.)?"?([\w$]+)"?\s+ON\s+("?[\w$]+"?\.)?"?([\w$]+)"?/i))) {
    const schema = (m[3] || '').replace(/\.$/, '').replace(/"/g, '') || 'public';
    const tableName = m[4].replace(/"/g, '');
    const indexName = m[2].replace(/"/g, '');
    const tableKey = `${schema}.${tableName}`;
    const entry = getEntry(tableKey);

    if (/_pkey$/i.test(indexName) && (entry.droppedPkConstraints.size > 0 || indexName.toLowerCase() === `${tableName.toLowerCase()}_pkey`)) {
      entry.pkRenamingStmts.push(s + ';');
    } else {
      entry.regularStmts.push(s + ';');
    }
    continue;
  }

  // 4. DROP INDEX IF EXISTS schema.index_name
  if ((m = oneLine.match(/\bDROP\s+INDEX\s+(?:IF\s+EXISTS\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))) {
    const schema = (m[1] || '').replace(/\.$/, '').replace(/"/g, '') || 'public';
    const indexName = m[2].replace(/"/g, '');
    unassignedDropIndexes.push({ fullStmt: s + ';', schema, indexName });
    continue;
  }

  // 5. Generic CREATE / ALTER / DROP TABLE
  if ((m = oneLine.match(/\bCREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))
   || (m = oneLine.match(/\bALTER\s+TABLE\s+(?:ONLY\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))
   || (m = oneLine.match(/\bDROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?("?[\w$]+"?\.)?"?([\w$]+)"?/i))) {
    const schema = (m[1] || '').replace(/\.$/, '').replace(/"/g, '') || 'public';
    const tableName = m[2].replace(/"/g, '');
    const tableKey = `${schema}.${tableName}`;
    const entry = getEntry(tableKey);
    entry.regularStmts.push(s + ';');
    continue;
  }

  // Fallback for everything else
  misc.push(s + ';');
}

// Second pass: Assign DROP INDEX statements to their corresponding tables
for (const dropIdx of unassignedDropIndexes) {
  let assigned = false;
  for (const [tableKey, entry] of tableData.entries()) {
    if (entry.droppedPkConstraints.has(dropIdx.indexName)) {
      entry.pkRenamingStmts.push(dropIdx.fullStmt);
      assigned = true;
      break;
    }
  }
  if (!assigned) {
    const cleanIndex = dropIdx.indexName.replace(/^(?:PK_|pk_)/i, '').toLowerCase();
    for (const [tableKey, entry] of tableData.entries()) {
      const cleanTable = tableKey.split('.')[1].toLowerCase();
      if (cleanIndex === cleanTable) {
        entry.pkRenamingStmts.push(dropIdx.fullStmt);
        assigned = true;
        break;
      }
    }
  }
  if (!assigned) {
    misc.push(dropIdx.fullStmt);
  }
}

// Format Markdown Output
let md = '';
if (tableData.size === 0 && misc.length === 0) {
  md = '_No differences._\n';
} else {
  const tables = [...tableData.keys()].sort((a, b) => a.localeCompare(b));
  for (const t of tables) {
    const entry = tableData.get(t);
    const hasRegular = entry.regularStmts.length > 0;
    const hasPkRenaming = entry.pkRenamingStmts.length > 0;

    if (!hasRegular && !hasPkRenaming) continue;

    md += `## ${t}\n\n`;

    if (hasRegular) {
      md += '```sql\n' + entry.regularStmts.join('\n\n') + '\n```\n\n';
    }

    if (hasPkRenaming) {
      md += '<details>\n<summary>Primary Key Renaming Constraints (EF Core)</summary>\n\n';
      md += '```sql\n' + entry.pkRenamingStmts.join('\n\n') + '\n```\n</details>\n\n';
    }
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
