#!/usr/bin/env bash
# Cross-platform wrapper: runs validate-all.ps1 via pwsh (PowerShell 7+).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v pwsh >/dev/null 2>&1; then
  echo "Error: pwsh (PowerShell 7+) is required. See docs/INSTALL.md" >&2
  exit 1
fi
exec pwsh -NoProfile -File "${SCRIPT_DIR}/validate-all.ps1" "$@"
