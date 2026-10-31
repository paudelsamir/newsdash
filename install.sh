#!/usr/bin/env bash
set -euo pipefail

if ! command -v omarchy >/dev/null 2>&1; then
  echo "omarchy was not found. Install Omarchy first." >&2
  exit 1
fi

target="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/paudelsamir.newsdash"

if [[ -e $target || -L $target ]]; then
  echo "NewsDash is already installed. Updating it instead."
  omarchy plugin update paudelsamir.newsdash --yes
else
  omarchy plugin add https://github.com/paudelsamir/newsdash.git --enable --yes
fi

omarchy restart shell
