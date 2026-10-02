#!/usr/bin/env bash

get_latest_changelog() {
    mkdir -p "$OUTPUT_DIR"

    sed -n '/^## /,$p' "$ROOT_DIR/.github/docs/CHANGELOG.md" \
        | sed -n '1p;2,/^## /p' \
        | sed '$d' \
        > "$OUTPUT_DIR/latest_changelog.md"
}
