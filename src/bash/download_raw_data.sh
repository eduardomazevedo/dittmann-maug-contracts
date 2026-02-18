#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "pyproject.toml" ]]; then
  echo "Run this script from the project root." >&2
  exit 1
fi

if [[ ! -f ".env" ]]; then
  echo "Missing .env in project root." >&2
  exit 1
fi

set -a
source .env
set +a

mkdir -p data/raw

REMOTE_BASE="dropbox:/Eduardo Azevedo/working/2026-dittmann-maug-replication"

PARQUET_FILES=(
  "data/execucomp/anncomp.parquet"
  "data/execucomp/codirfin.parquet"
  "data/execucomp/colev.parquet"
  "data/execucomp/coperol.parquet"
  "data/execucomp/deferredcomp.parquet"
  "data/execucomp/directorcomp.parquet"
  "data/execucomp/ex_black.parquet"
  "data/execucomp/ex_header.parquet"
  "data/execucomp/exnames.parquet"
  "data/execucomp/ltawdtab.parquet"
  "data/execucomp/outstandingawards.parquet"
  "data/execucomp/pension.parquet"
  "data/execucomp/person.parquet"
  "data/execucomp/planbasedawards.parquet"
  "data/execucomp/stgrttab.parquet"
  "data/out/stage1_contract_inputs_1995.parquet"
  "data/out/stage1_contract_inputs_2000.parquet"
)

echo "Downloading ${#PARQUET_FILES[@]} parquet files into data/raw/..."

for rel_path in "${PARQUET_FILES[@]}"; do
  local_path="data/raw/$(basename "$rel_path")"
  remote_path="$REMOTE_BASE/$rel_path"

  echo "-> $rel_path"
  rclone copyto "$remote_path" "$local_path"
done

echo "Done. Files are in data/raw/."