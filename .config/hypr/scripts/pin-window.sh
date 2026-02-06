#!/usr/bin/env bash
set -euo pipefail

addr="${1:-}"

if [[ -z "$addr" ]]; then
    echo "Usage: $0 <window-address>" >&2
    exit 1
fi

# Validate address format (basic sanity check)
if [[ ! "$addr" =~ ^0x[0-9a-fA-F]+$ ]]; then
    echo "Invalid window address: $addr" >&2
    exit 1
fi

hyprctl dispatch pin "address:$addr"
