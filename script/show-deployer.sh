#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$line" ] && continue
    key="$(printf '%s' "$line" | sed 's/[[:space:]]*=.*$//')"
    value="$(printf '%s' "$line" | sed 's/^[^=]*=[[:space:]]*//')"
    value="$(printf '%s' "$value" | sed 's/^["'\"']//;s/["'\"']$//')"
    export "$key=$value"
  done < .env
fi

: "${PRIVATE_KEY:?PRIVATE_KEY is required in .env}"

cast wallet address --private-key "$PRIVATE_KEY"
