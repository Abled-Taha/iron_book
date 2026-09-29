#!/usr/bin/env bash

# ==============================================================================
# Versioning
# ==============================================================================

update_api_version() {
    local version="$1"

    echo "📦 Updating API version to $version..."

    sed -i -E \
        '0,/^version = "[^"]+"/s//version = "'"$version"'"/' \
        "$API_CARGO_TOML"

    echo "✔ API version updated."
}

update_home_version() {
    local version="$1"

    echo "📦 Updating Home version to $version..."

    (
        cd "$HOME_DIR"
        npm pkg set version="$version"
    )

    echo "✔ Home version updated."
}

update_desktop_version() {
    local version="$1"

    echo "📦 Updating Desktop version to $version..."

    sed -i -E \
        's|<Version>[^<]+</Version>|<Version>'"$version"'</Version>|' \
        "$DESKTOP_PROJECT_FILE"

    echo "✔ Desktop version updated."
}

update_android_version() {
    local version="$1"

    echo "📦 Updating Android version to $version..."

    # Parse major.minor.patch and optional prerelease.
    local major minor patch prerelease
    IFS='.' read -r major minor patch <<< "${version%%-*}"

    prerelease=""
    if [[ "$version" == *-* ]]; then
        prerelease="${version#*-}"
    fi

    # Base versionCode:
    #
    #   major * 1,000,000
    #   minor * 10,000
    #   patch * 100
    #
    # The final two digits are reserved for prerelease information.
    local version_code=$((major * 1000000 + minor * 10000 + patch * 100))

    # Encode prerelease channel:
    #
    #   stable = 00
    #   alpha  = 10 + number
    #   beta   = 40 + number
    #   rc     = 70 + number
    #
    # Examples:
    #
    #   0.1.0          -> 10000
    #   0.1.0-alpha    -> 10010
    #   0.1.0-alpha.1  -> 10011
    #   0.1.0-beta     -> 10040
    #   0.1.0-beta.1   -> 10041
    #   0.1.0-rc       -> 10070

    if [[ -n "$prerelease" ]]; then
        local channel="${prerelease%%.*}"
        local prerelease_number=0

        if [[ "$prerelease" == *.* ]]; then
            prerelease_number="${prerelease#*.}"
        fi

        case "$channel" in
            alpha)
                version_code=$((version_code + 10 + prerelease_number))
                ;;
            beta)
                version_code=$((version_code + 40 + prerelease_number))
                ;;
            rc)
                version_code=$((version_code + 70 + prerelease_number))
                ;;
            *)
                echo "❌ Unsupported prerelease channel: $channel"
                echo "Expected alpha, beta, or rc."
                return 1
                ;;
        esac
    fi

    sed -i -E \
        's/versionName = "[^"]+"/versionName = "'"$version"'"/' \
        "$ANDROID_BUILD_GRADLE"

    sed -i -E \
        's/versionCode = [0-9]+/versionCode = '"$version_code"'/' \
        "$ANDROID_BUILD_GRADLE"

    echo "✔ Android version updated."
}

update_windows_installer_version() {
    local version="$1"

    echo "📦 Updating Windows installer version to $version..."

    sed -i -E \
        's|^AppVersion=.*$|AppVersion='"$version"'|' \
        "scripts/windows_installer.iss"

    echo "✔ Windows installer version updated."
}

cmd_update_version() {
    local version="${1:-}"

    require_version "$version" "update-version"

    update_api_version "$version"
    update_home_version "$version"
    update_desktop_version "$version"
    update_android_version "$version"
    update_windows_installer_version "$version"

    echo ""
    echo "✔ Version updated to $version"
}

# ==============================================================================
# API Build
# ==============================================================================

build_api() {
    echo "🔨 Building API..."

    (
        cd "$API_DIR"

        cargo build --release
        cargo build --target x86_64-pc-windows-gnu --release
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

        pnpm build
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

        dotnet publish \
            -c Release \
            -r linux-x64 \
            --self-contained true \
            -o output/linux

        dotnet publish \
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

    (
        cd "$SCRIPT_DIR/scripts"
        echo "$PWD"
        docker run --rm -v "$(pwd):/work" amake/innosetup windows_installer.iss
    )

    echo "✔ Windows Installer build complete."
}

# ==============================================================================
# API Packaging
# ==============================================================================

package_api() {
    local version="$1"

    local linux_archive="$API_LINUX_OUTPUT/ironbook-api-v${version}-linux-x64.zip"
    local windows_archive="$API_WINDOWS_OUTPUT/ironbook-api-v${version}-win-x64.zip"

    echo "📦 Packaging API..."

    mkdir -p "$API_LINUX_OUTPUT" "$API_WINDOWS_OUTPUT"

    rm -f "$linux_archive" "$windows_archive"

    local linux_tmp
    local windows_tmp

    linux_tmp=$(mktemp -d)
    windows_tmp=$(mktemp -d)

    # Linux
    cp "$API_DIR/target/release/ironbook_api" \
        "$linux_tmp/ironbook_api"

    cp "$API_DIR/.env.example" \
        "$linux_tmp/.env"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$linux_tmp/latest_changelog.md"

    (
        cd "$linux_tmp"
        zip -q -r "$OLDPWD/$linux_archive" .
    )

    # Windows
    cp "$API_DIR/target/x86_64-pc-windows-gnu/release/ironbook_api.exe" \
        "$windows_tmp/ironbook_api.exe"

    cp "$API_DIR/.env.example" \
        "$windows_tmp/.env"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$windows_tmp/latest_changelog.md"

    (
        cd "$windows_tmp"
        zip -q -r "$OLDPWD/$windows_archive" .
    )

    rm -rf "$linux_tmp" "$windows_tmp"

    echo "✔ Created:"
    echo "  $linux_archive"
    echo "  $windows_archive"
}

# ==============================================================================
# Home Packaging
# ==============================================================================

package_home() {
    local version="$1"

    local home_build_dir="$HOME_DIR/out"
    local archive="$HOME_OUTPUT/ironbook-home-v${version}.zip"

    echo "📦 Packaging Home..."

    if [[ ! -d "$home_build_dir" ]]; then
        echo "❌ Home build directory not found: $home_build_dir"
        return 1
    fi

    mkdir -p "$HOME_OUTPUT"

    rm -f "$archive"

    local tmp
    tmp=$(mktemp -d)

    cp -a "$home_build_dir"/. "$tmp/"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$tmp/latest_changelog.md"

    (
        cd "$tmp"
        zip -q -r "$OLDPWD/$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}

# ==============================================================================
# Desktop Packaging
# ==============================================================================

package_desktop() {
    local version="$1"

    local linux_archive="$DESKTOP_LINUX_OUTPUT/ironbook-desktop-v${version}-linux-x64.zip"
    local windows_archive="$DESKTOP_WINDOWS_OUTPUT/ironbook-desktop-v${version}-win-x64.zip"

    echo "📦 Packaging Desktop..."

    mkdir -p "$DESKTOP_LINUX_OUTPUT" "$DESKTOP_WINDOWS_OUTPUT"

    rm -f "$linux_archive" "$windows_archive"

    local linux_tmp
    local windows_tmp

    linux_tmp=$(mktemp -d)
    windows_tmp=$(mktemp -d)

    # Linux
    cp -a "$DESKTOP_DIR/output/linux"/. \
        "$linux_tmp/"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$linux_tmp/latest_changelog.md"

    (
        cd "$linux_tmp"
        zip -q -r "$OLDPWD/$linux_archive" .
    )

    # Windows
    cp -a "$DESKTOP_DIR/output/windows"/. \
        "$windows_tmp/"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$windows_tmp/latest_changelog.md"

    (
        cd "$windows_tmp"
        zip -q -r "$OLDPWD/$windows_archive" .
    )

    rm -rf "$linux_tmp" "$windows_tmp"

    echo "✔ Created:"
    echo "  $linux_archive"
    echo "  $windows_archive"
}

# ==============================================================================
# Android Packaging
# ==============================================================================

package_android() {
    local version="$1"

    local archive="$ANDROID_OUTPUT/ironbook-android-v${version}-android-x64.zip"

    echo "📦 Packaging Android..."

    mkdir -p "$ANDROID_OUTPUT"

    rm -f "$archive"

    local tmp
    tmp=$(mktemp -d)

    cp "$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk" \
        "$tmp/ironbook_android.apk"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$tmp/latest_changelog.md"

    (
        cd "$tmp"
        zip -q -r "$OLDPWD/$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}

# ==============================================================================
# Windows Installer Packaging
# ==============================================================================

package_windows_installer() {
    local version="$1"

    local archive="$WINDOWS_INSTALLER_OUTPUT/ironbook-installer-v${version}-win-x64.exe"

    echo "📦 Packaging Windows Installer..."

    mkdir -p "$WINDOWS_INSTALLER_OUTPUT"

    rm -f "$archive"

    local tmp

    tmp=$(mktemp -d)

    cp "$SCRIPT_DIR/scripts/Output/IronBook-Setup.exe" \
        "$tmp/ironbook_Installer.exe"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$tmp/latest_changelog.md"

    (
        cd "$tmp"
        zip -q -r "$OLDPWD/$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}

# ==============================================================================
# Signing
# ==============================================================================

sign_release_files() {
    if [[ -z "${RELEASE_GPG_KEY:-}" ]]; then
        echo "❌ RELEASE_GPG_KEY is not set."
        echo ""
        echo "Set it in your environment or .env:"
        echo "  RELEASE_GPG_KEY=<fingerprint>"
        return 1
    fi

    echo "🔐 Signing release files..."

    local found=0

    while IFS= read -r -d '' file; do
        found=1

        echo "  Signing $(basename "$file")"

        gpg \
            --batch \
            --yes \
            --local-user "$RELEASE_GPG_KEY" \
            --detach-sign \
            --armor \
            "$file"

    done < <(
        find "$OUTPUT_DIR" \
            -type f \
            -name '*.zip' \
            -print0
    )

    if [[ "$found" -eq 0 ]]; then
        echo "❌ No release archives found to sign."
        return 1
    fi

    echo "✔ Release files signed."
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
                echo "Usage: ./ironbook.sh build <version> [options]"
                echo "Options:"
                echo "  --no-sign    Skip signing release files."
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
    cmd_get_latest_changelog

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
