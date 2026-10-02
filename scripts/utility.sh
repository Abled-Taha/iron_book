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
