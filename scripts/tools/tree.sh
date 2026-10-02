#!/usr/bin/env bash

cmd_tree() {
    cmd_exists "tree" || return 1

    echo "🌳 Generating directory tree..."

    local tree_output
    tree_output=$(tree -a --gitignore -I ".git")

    echo "$tree_output"
}
