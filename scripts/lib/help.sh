#!/usr/bin/env bash

cmd_help() {
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
