#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/vars.sh"

source "$SCRIPTS_DIR/lib/utility.sh"
source "$SCRIPTS_DIR/build/build.sh"
source "$SCRIPTS_DIR/tools/get_codebase.sh"
source "$SCRIPTS_DIR/tools/tree.sh"
source "$SCRIPTS_DIR/lib/help.sh"
source "$SCRIPTS_DIR/release/get_latest_changelog.sh"

# ==============================================================================
# Main Command Router
# ==============================================================================

COMMAND="${1:-help}"

case "$COMMAND" in
    tree)
        cmd_tree
        ;;

    get-codebase)
        cmd_get_codebase
        ;;

    get-latest-changelog)
        get_latest_changelog
        ;;

    update-version)
        shift
        cmd_update_version "$@"
        ;;

    build)
        shift
        cmd_build "$@"
        ;;

    setup)
        source "$SCRIPTS_DIR/setup/setup.sh"
        ;;

    help|--help|-h)
        cmd_help
        ;;

    *)
        echo "❌ Unknown command: '$COMMAND'"
        echo ""
        cmd_help
        exit 1
        ;;
esac
