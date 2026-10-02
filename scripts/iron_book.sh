#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/vars.sh"

source "$SCRIPTS_DIR/utility.sh"
source "$SCRIPTS_DIR/build.sh"
source "$SCRIPTS_DIR/tools/get_codebase.sh"

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
        cmd_get_latest_changelog
        ;;

    update-version)
        shift
        cmd_update_version "$@"
        ;;

    build)
        shift
        cmd_build "$@"
        ;;

    help|--help|-h)
        usage
        ;;

    *)
        echo "❌ Unknown command: '$COMMAND'"
        echo ""
        usage
        exit 1
        ;;
esac
