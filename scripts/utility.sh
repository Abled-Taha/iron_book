#!/usr/bin/env bash

cmd_exists() {
    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        echo "❌ Required command not found: $command"
        return 1
    fi
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
