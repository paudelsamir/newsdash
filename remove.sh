#!/usr/bin/env bash
set -euo pipefail

if ! command -v omarchy >/dev/null 2>&1; then
  echo "omarchy was not found. Nothing to remove." >&2
  exit 1
fi

omarchy plugin remove paudelsamir.newsdash --yes
omarchy restart shell
