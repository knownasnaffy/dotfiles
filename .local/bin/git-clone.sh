#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: gcl <repo> [git clone options...]"
    exit 1
fi

input="$1"
shift

normalize_github() {
    local path="$1"

    # remove protocol + domain if present
    path="${path#https://github.com/}"
    path="${path#http://github.com/}"
    path="${path#github.com/}"

    # remove trailing .git
    path="${path%.git}"

    echo "git@github.com:${path}.git"
}

normalize_aur() {
    local path="$1"

    # strip protocol + domain
    path="${path#https://aur.archlinux.org/}"
    path="${path#http://aur.archlinux.org/}"

    # strip packages/
    path="${path#packages/}"

    # remove trailing .git
    path="${path%.git}"

    echo "ssh://aur@aur.archlinux.org/${path}.git"
}

# Already SSH → pass through
if [[ "$input" =~ ^git@ ]] || [[ "$input" =~ ^ssh:// ]]; then
    git clone "$input" "$@"
    exit 0
fi

# GitHub full URL
if [[ "$input" =~ github\.com ]]; then
    git clone "$(normalize_github "$input")" "$@"
    exit 0
fi

# AUR
if [[ "$input" =~ aur\.archlinux\.org ]]; then
    git clone "$(normalize_aur "$input")" "$@"
    exit 0
fi

# GitHub shorthand user/repo
if [[ "$input" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
    git clone "git@github.com:${input}.git" "$@"
    exit 0
fi

# Fallback: raw input
git clone "$input" "$@"
