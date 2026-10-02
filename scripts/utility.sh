#!/usr/bin/env bash

# ==============================================================================
# General Helpers
# ==============================================================================

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
        cmd_help
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
# Latest Changelog
# ==============================================================================

cmd_get_latest_changelog() {
    mkdir -p "$OUTPUT_DIR"

    sed -n '/^## /,$p' "$ROOT_DIR/.github/docs/CHANGELOG.md" \
        | sed -n '1p;2,/^## /p' \
        | sed '$d' \
        > "$OUTPUT_DIR/latest_changelog.md"
}
