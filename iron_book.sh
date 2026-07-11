#!/bin/bash

source ./scripts/utility.sh

# Command Functions

cmd_help() {
    echo "Usage: ./iron_book.sh [command]"
    echo ""
    echo "Commands:"
    echo "  tree    Generate directory structure while keeping the .gitignore file in context."
    echo "  help    Show this help menu"
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

# --- Main Command Router ---

case "$1" in
    tree)
        cmd_tree
        ;;
    help|--help|-h|"")
        cmd_help
        ;;
    *)
        echo "❌ Unknown command: '$1'"
        cmd_help
        exit 1
        ;;
esac
