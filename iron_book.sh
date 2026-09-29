#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/utility.sh"
source "$SCRIPT_DIR/scripts/build.sh"

# ==============================================================================
# Configuration
# ==============================================================================

API_DIR="apps/api"
API_CARGO_TOML="$API_DIR/Cargo.toml"

HOME_DIR="apps/home"

DESKTOP_DIR="apps/desktop"
DESKTOP_PROJECT_FILE="$DESKTOP_DIR/ironbook.csproj"

ANDROID_DIR="apps/android"
ANDROID_BUILD_GRADLE="$ANDROID_DIR/app/build.gradle.kts"

OUTPUT_DIR="output"

API_LINUX_OUTPUT="$OUTPUT_DIR/api/linux"
API_WINDOWS_OUTPUT="$OUTPUT_DIR/api/windows"

HOME_OUTPUT="$OUTPUT_DIR/home"

DESKTOP_LINUX_OUTPUT="$OUTPUT_DIR/desktop/linux"
DESKTOP_WINDOWS_OUTPUT="$OUTPUT_DIR/desktop/windows"

ANDROID_OUTPUT="$OUTPUT_DIR/android"

WINDOWS_INSTALLER_OUTPUT="$OUTPUT_DIR/installer/"

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
