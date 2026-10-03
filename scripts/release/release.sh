#!/usr/bin/env bash

cmd_release() {
    local version="${1:-}"
    local no_sign=0

    require_version "$version" || return 1

    shift || true

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-sign)
                no_sign=1
                ;;
            *)
                echo "❌ Unknown release option: '$1'"
                cmd_help
                return 1
                ;;
        esac

        shift
    done

    echo ""
    echo "========================================"
    echo " Releasing IronBook $version"
    echo "========================================"
    echo ""

    echo "📝 Updating versions..."
    cmd_update_version "$version"

    echo "🔨 Building release..."
    cmd_build "$version"

    if [[ "$no_sign" -eq 0 ]]; then
        sign_release_files
    else
        echo "⏭️  Skipping release signing (--no-sign)."
    fi

    echo ""
    echo "========================================"
    echo " ✔ Release $version complete"
    echo "========================================"
}
