#!/usr/bin/env bash

# ==============================================================================
# Helpers
# ==============================================================================

require_version() {
    local version="${1:-}"
    local command="${2:-}"

    if [[ -z "$version" ]]; then
        echo "❌ Version is required."
        cmd_help
        return 1
    fi

    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
        echo "❌ Invalid version: $version"
        echo "Expected something like: 0.1.0, 0.1.0-alpha, or 1.2.3-beta.1"
        return 1
    fi
}

# ==============================================================================
# API Build
# ==============================================================================

build_api() {
    echo "🔨 Building API..."

    export SQLX_OFFLINE=true
    (
        cd "$API_DIR"

        mise exec -- cargo build --release
        mise exec -- cargo build --target x86_64-pc-windows-gnu --release
    )

    echo "✔ API build complete."
}

# ==============================================================================
# Home Build
# ==============================================================================

build_home() {
    echo "🔨 Building Home..."

    (
        cd "$HOME_DIR"

        mise exec -- pnpm build
    )

    echo "✔ Home build complete."
}

# ==============================================================================
# Desktop Build
# ==============================================================================

build_desktop() {
    echo "🔨 Building Desktop..."

    (
        cd "$DESKTOP_DIR"

        mise exec -- dotnet publish \
            -c Release \
            -r linux-x64 \
            --self-contained true \
            -o output/linux

        mise exec -- dotnet publish \
            -c Release \
            -r win-x64 \
            --self-contained true \
            -o output/windows
    )

    echo "✔ Desktop build complete."
}

# ==============================================================================
# Android Build
# ==============================================================================

build_android() {
    echo "🔨 Building Android..."

    (
        cd "$ANDROID_DIR"

        ./gradlew assembleRelease
    )

    echo "✔ Android build complete."
}

# ==============================================================================
# Windows Installer Build
# ==============================================================================

build_windows_installer() {
    echo "🔨 Building Windows Installer..."

    local installer_dir
    installer_dir="$(mktemp -d)"

    mkdir -p "$WINDOWS_INSTALLER_OUTPUT"

    cp "$SCRIPTS_DIR/install/windows/installer.iss" \
        "$installer_dir/installer.iss"

    cp "$SCRIPTS_DIR/install/windows/fetch_and_install.ps1" \
        "$installer_dir/fetch_and_install.ps1"

    mkdir -p "$installer_dir/Output"

    chmod -R a+rwx "$installer_dir"

    docker run --rm \
        -v "$installer_dir:/work" \
        amake/innosetup \
        /work/installer.iss

    cp "$installer_dir/Output/IronBook-Setup.exe" \
        "$WINDOWS_INSTALLER_OUTPUT/IronBook-Setup.exe"

    rm -rf "$installer_dir"

    echo "✔ Windows Installer build complete."
}

# ==============================================================================
# Release Build
# ==============================================================================

cmd_build() {
    local version="${1:-}"
    local no_sign=0

    require_version "$version" "build"

    shift || true

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-sign)
                no_sign=1
                ;;

            *)
                echo "❌ Unknown build option: '$1'"
                echo ""
                cmd_help
                return 1
                ;;
        esac

        shift
    done

    echo ""
    echo "========================================"
    echo " Building IronBook $version"
    echo "========================================"
    echo ""

    # Each project follows the same release flow:
    #
    #   update version
    #   build
    #   package
    #
    # Add future projects here using the same structure.

    # --- Nuke output ---
    rm -rf output

    # --- Changelog ---
    update_changelog_version "$version"
    get_latest_changelog

    # --- API ---
    update_api_version "$version"
    build_api
    package_api "$version"

    # --- Home ---
    update_home_version "$version"
    build_home
    package_home "$version"

    # --- Desktop ---
    update_desktop_version "$version"
    build_desktop
    package_desktop "$version"

    # --- Android ---
    update_android_version "$version"
    build_android
    package_android "$version"

    # --- Windows Installer ---
    update_windows_installer_version "$version"
    build_windows_installer
    package_windows_installer "$version"

    # --- Web ---
    update_web_version "$version"

    # --- Sign ---
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
