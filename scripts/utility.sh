#!/usr/bin/env bash

# ==============================================================================
# General Helpers
# ==============================================================================

usage() {
    echo "Usage: ./ironbook.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  tree                    Generate directory structure."
    echo "  get-codebase            Generate the entire codebase in codebase.txt."
    echo "  update-version <ver>    Update project versions."
    echo "  build <ver> [options]   Build, package, and sign a release."
    echo "    --no-sign             Skip signing release files."
    echo "  help                    Show this help menu."
    echo "  get-latest-changelog    Compile the changelog for the latest build."
}

cmd_exists() {
    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        echo "❌ Required command not found: $command"
        return 1
    fi
}

require_version() {
    local version="${1:-}"
    local command="${2:-}"

    if [[ -z "$version" ]]; then
        echo "❌ Version is required."
        echo "Usage: ./ironbook.sh $command <version>"
        echo "Example: ./ironbook.sh $command 0.1.0-alpha"
        return 1
    fi

    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
        echo "❌ Invalid version: $version"
        echo "Expected something like: 0.1.0, 0.1.0-alpha, or 1.2.3-beta.1"
        return 1
    fi
}

get_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "${ID:-unknown}"
        return
    fi

    if command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
        return
    fi

    echo "unknown"
}

# ==============================================================================
# Tree
# ==============================================================================

cmd_tree() {
    cmd_exists "tree" || return 1

    echo "🌳 Generating directory tree..."

    local tree_output
    tree_output=$(tree -a --gitignore -I ".git")

    echo "$tree_output"
}

# ==============================================================================
# Latest Changelog
# ==============================================================================

cmd_get_latest_changelog() {
    mkdir -p "$OUTPUT_DIR"

    sed -n '/^## /,$p' "$ROOT_DIR/.github/docs/CHANGELOG.md" \
        | sed -n '1p;2,/^## /p' \
        | sed '$d' \
        > "$OUTPUT_DIR/latest_changelog.md"
}
