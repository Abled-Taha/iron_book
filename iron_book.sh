#!/bin/bash

source ./scripts/utility.sh

# Command Functions

cmd_help() {
    echo "Usage: ./iron_book.sh [command]"
    echo ""
    echo "Commands:"
    echo "  tree            Generate directory structure while keeping the .gitignore file in context."
    echo "  help            Show this help menu."
    echo "  get_codebase    Generates the entire codebase in a single file, to be pasted in LLM."
}

cmd_tree() {
    # Check if tree is installed before running it
    cmd_exists "tree" || return 1

    echo "🌳 Generating directory tree..."

    # -I ignores common clutter folders.
    local tree_output
    tree_output=$(tree -a --gitignore -I ".git")

    # Double quotes preserve the line breaks/formatting of the tree
    echo "$tree_output"
}

cmd_get_codebase() {
    local output_file="codebase.txt"

    # 1. Initialize file and generate Directory Tree
    echo "=== DIRECTORY TREE ===" > "$output_file"

    # Exclude common large/compiled/dependency directories and the output file from the tree visualizer
    tree -a -I "node_modules|build|dist|target|.git|.env|__pycache__|.next|.cache|.gradle|.venv|.idea|.android_sdk|.mise|$output_file" >> "$output_file"

    echo -e "\n=== FILE CONTENTS ===" >> "$output_file"

    # 2. Complete isolation of directory pruning from file retrieval
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

        # Strip leading "./" for cleaner pattern matching
        local clean_file="${file#./}"

        # Rule 1: Exclude lockfiles, assets, and binary files
        case "$clean_file" in
            # Lockfiles and system configs
            *pnpm-lock.yaml|*package-lock.json|*yarn.lock|*uv.lock|*Cargo.lock|*poetry.lock|*.DS_Store)
                continue
                ;;
            # Web assets / Images
            *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.webp)
                continue
                ;;
            # Documents and Binaries
            *.pdf|*.zip|*.tar.gz|*.rar|*.bin|*.exe|*.so|*.dll|*.dylib|*.jar|*.lock)
                continue
                ;;
            # Environment configurations
            *.env|*.env.*)
                continue
                ;;
        esac

        # Rule 2: Git environment check (respect local .gitignore rules if present)
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if git check-ignore -q "$clean_file"; then
                continue
            fi
        fi

        # Append the header and file content
        echo -e "\n==> $clean_file <==" >> "$output_file"
        cat "$file" >> "$output_file"
    done

    echo "✔ Codebase successfully compiled to $output_file without monorepo noise."
}

# --- Main Command Router ---

case "$1" in
    tree)
        cmd_tree
        ;;
    help|--help|-h|"")
        cmd_help
        ;;
    get_codebase)
        cmd_get_codebase
        ;;
    *)
        echo "❌ Unknown command: '$1'"
        cmd_help
        exit 1
        ;;
esac
