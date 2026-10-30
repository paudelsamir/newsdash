#!/usr/bin/env bash
set -euo pipefail

if ! command -v omarchy >/dev/null 2>&1; then
  echo "omarchy was not found. Install Omarchy first." >&2
  exit 1
fi

omarchy plugin add https://github.com/paudelsamir/newsdash.git --enable --yes
omarchy restart shell
