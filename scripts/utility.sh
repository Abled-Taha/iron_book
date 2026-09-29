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
# Codebase
# ==============================================================================

cmd_get_codebase() {
    local output_file="codebase.txt"

    echo "=== DIRECTORY TREE ===" > "$output_file"

    tree -a \
        -I "node_modules|build|dist|target|.git|.env|__pycache__|.next|.cache|.gradle|.venv|.idea|.android_sdk|.mise|$output_file" \
        >> "$output_file"

    echo -e "\n=== FILE CONTENTS ===" >> "$output_file"

    find . \( \
        -type d -name "node_modules" -o \
        -type d -name "build" -o \
        -type d -name "dist" -o \
        -type d -name "target" -o \
        -type d -name ".git" -o \
        -type d -name "__pycache__" -o \
        -type d -name ".next" -o \
        -type d -name ".cache" -o \
        -type d -name ".gradle" -o \
        -type d -name ".venv" -o \
        -type d -name ".idea" -o \
        -type d -name ".android_sdk" -o \
        -type d -name ".mise" \
    \) -prune -o -type f ! -name "$output_file" | while read -r file; do

        local clean_file="${file#./}"

        case "$clean_file" in
            *pnpm-lock.yaml|*package-lock.json|*yarn.lock|*uv.lock|*Cargo.lock|*poetry.lock|*.DS_Store)
                continue
                ;;
            *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.webp)
                continue
                ;;
            *.pdf|*.zip|*.tar.gz|*.rar|*.bin|*.exe|*.so|*.dll|*.dylib|*.jar|*.lock)
                continue
                ;;
            *.env|*.env.*)
                continue
                ;;
        esac

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if git check-ignore -q "$clean_file"; then
                continue
            fi
        fi

        echo -e "\n==> $clean_file <==" >> "$output_file"
        cat "$file" >> "$output_file"
    done

    echo "✔ Codebase successfully compiled to $output_file."
}

# ==============================================================================
# Latest Changelog
# ==============================================================================

cmd_get_latest_changelog() {
    mkdir -p "$OUTPUT_DIR"

    sed -n '/^## /,$p' .github/docs/CHANGELOG.md \
        | sed -n '1p;2,/^## /p' \
        | sed '$d' \
        > "$OUTPUT_DIR/latest_changelog.md"
}
