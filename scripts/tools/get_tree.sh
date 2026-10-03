#!/usr/bin/env bash

cmd_get_tree() {
    cmd_exists "tree" || return 1

    local output_file="tree.txt"

    local tree_output
    tree_output=$(tree -a --gitignore -I ".git")

    echo "$tree_output" > "$output_file"

    echo "🌳 Generated directory tree."
}
