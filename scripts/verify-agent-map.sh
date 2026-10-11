#!/usr/bin/env bash
# ==============================================================================
# verify-agent-map.sh — Validasi Integritas Jalur File di AGENT_MANIFEST.md
# ==============================================================================
# Menjaga integritas 'Single Source of Truth' agar tidak terjadi 'Stale Documentation'.
# Jika file berpindah atau dihapus tanpa mengupdate AGENT_MANIFEST.md,
# skrip ini akan mengembalikan exit code 1 dan memblokir git commit.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$PROJECT_ROOT/AGENT_MANIFEST.md"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "Error: File $MANIFEST_FILE tidak ditemukan!"
  exit 1
fi

echo "=========================================================="
echo "Memeriksa integritas path di AGENT_MANIFEST.md..."
echo "=========================================================="

MISSING_COUNT=0
TOTAL_CHECKED=0

# Ekstrak semua path file (lib/*.dart, src/*) dari tabel markdown
PATHS=$(grep -oE '\((file:///[^)]+|lib/[a-zA-Z0-9_/.-]+|src/[a-zA-Z0-9_/.-]+)\)' "$MANIFEST_FILE" | sed -E 's/^\((file:\/\/\/[^)]*\/project\/snapan-market-mobile\/)?//; s/\)$//' | grep -v '^#' | sort -u)

while read -r rel_path; do
  [ -z "$rel_path" ] && continue
  
  clean_path=$(echo "$rel_path" | sed -E 's|^.*/snapan-market-mobile/||')
  TARGET_PATH="$PROJECT_ROOT/$clean_path"
  TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
  
  if [ -e "$TARGET_PATH" ]; then
    echo "  [OK] $clean_path"
  else
    echo "  [MISSING!] $clean_path"
    MISSING_COUNT=$((MISSING_COUNT + 1))
  fi
done <<< "$PATHS"

echo "=========================================================="
if [ "$MISSING_COUNT" -eq 0 ]; then
  echo "SEMUA PATH MANIFEST VALID ($TOTAL_CHECKED file diperiksa, 0 missing)."
  echo "AGENT_MANIFEST.md 100% sinkron dengan codebase aktual."
  exit 0
else
  echo "ERROR: Ditemukan $MISSING_COUNT path usang di AGENT_MANIFEST.md!"
  echo "Harap perbaiki path di atas sebelum melakukan commit."
  exit 1
fi
