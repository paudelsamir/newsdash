#!/usr/bin/env bash
set -euo pipefail

if ! command -v omarchy >/dev/null 2>&1; then
  echo "omarchy was not found. Nothing to remove." >&2
  exit 1
fi

target="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/paudelsamir.newsdash"

if [[ ! -e $target && ! -L $target ]]; then
  echo "NewsDash is not installed. Nothing to remove."
  exit 0
fi

omarchy plugin remove paudelsamir.newsdash --yes
omarchy restart shell
