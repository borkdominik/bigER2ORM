#!/bin/sh
set -eu

# define DBs
DB1="postgresql://postgres:postgres@postgres:5432/csharp"
DB2="postgresql://postgres:postgres@postgres:5432/java"
DB3="postgresql://postgres:postgres@postgres:5432/python"

DB_REF_SAKILA="postgresql://postgres:postgres@postgres:5432/sakila_reference"
DB_REF_DST="postgresql://postgres:postgres@postgres:5432/dst_reference"

OUTDIR="/app/schema-diffs"

# IMPORTANT:
# 1) Leave SCHEMAS empty so all (non-system) schemas are compared.
#    Cross-schema FKs need both ends visible or the constraint may appear “missing”.
SCHEMAS="${SCHEMAS:-}"   # e.g., "public,analytics" ONLY if you truly want to restrict

# 2) Allow unsafe diffs (DROP/ALTER that migra considers dangerous).
#    The pgkit CLI mirrors python migra’s behavior; enabling “unsafe” lets the diff be produced.
MIGRA_FLAGS="${MIGRA_FLAGS:---unsafe}"

mkdir -p "$OUTDIR"
# remove previous artifacts but keep the dir
rm -rf "$OUTDIR"/*

# Base inter-framework pairs
pairs="
$DB1|$DB2
$DB1|$DB3
$DB2|$DB3
"

# Probe if sakila_reference DB exists using migra directly
if migra "$DB1" "$DB_REF_SAKILA" $MIGRA_FLAGS >/dev/null 2>&1; then
  echo "sakila_reference database detected. Including Sakila reference comparisons..."
  pairs="$pairs
$DB1|$DB_REF_SAKILA
$DB2|$DB_REF_SAKILA
$DB3|$DB_REF_SAKILA
"
fi

# Probe if dst_reference DB exists using migra directly
if migra "$DB1" "$DB_REF_DST" $MIGRA_FLAGS >/dev/null 2>&1; then
  echo "dst_reference database detected. Including DST reference comparisons..."
  pairs="$pairs
$DB1|$DB_REF_DST
$DB2|$DB_REF_DST
$DB3|$DB_REF_DST
"
fi

get_dbname() {
  # capture chars after the last '/' up to '?' (if present)
  name=$(printf "%s" "$1" | sed -E 's#.*/([^/?]+).*#\1#')
  # keep it filename-safe
  echo "$name" | sed -E 's/[^A-Za-z0-9_.-]/_/g'
}

build_schema_flags() {
  if [ -n "$SCHEMAS" ]; then
    # turn "a,b,c" into "--schema a --schema b --schema c"
    IFS=',' 
    for s in $SCHEMAS; do
      s="$(echo "$s" | sed -E 's/^ +| +$//g')"
      [ -n "$s" ] && printf -- "--schema %s " "$s"
    done
    IFS=' '
  fi
}

SCHEMA_FLAGS="$(build_schema_flags)"

echo "Starting pairwise comparisons..."
echo "Output directory: $OUTDIR"
[ -n "$SCHEMA_FLAGS" ] && echo "Schema filter: $SCHEMA_FLAGS" || echo "Schema filter: (all non-system schemas)"
echo "Migra flags: $MIGRA_FLAGS"

# Loop over all pairs
echo "$pairs" | while IFS='|' read -r src dst; do
  [ -z "$src" ] && continue
  srcn="$(get_dbname "$src")"
  dstn="$(get_dbname "$dst")"
  outfile="$OUTDIR/migra__${srcn}__to__${dstn}.sql"

  echo "----"
  echo "SOURCE: $src"
  echo "TARGET: $dst"
  echo "OUT:    $outfile"

  if [ -n "$SCHEMA_FLAGS" ]; then
    migra \
      "$src" \
      "$dst" \
      $MIGRA_FLAGS \
      $SCHEMA_FLAGS \
      > "$outfile" || true
  else
    migra \
      "$src" \
      "$dst" \
      $MIGRA_FLAGS \
      > "$outfile" || true
  fi

  [ -s "$outfile" ] || echo "-- No differences" > "$outfile"
  echo "Wrote $outfile"
done

echo "All comparisons complete."