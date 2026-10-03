#!/usr/bin/env bash

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
        zip -q -r "$linux_archive" .
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
        zip -q -r "$windows_archive" .
    )

    rm -rf "$linux_tmp" "$windows_tmp"

    echo "✔ Created:"
    echo "  $linux_archive"
    echo "  $windows_archive"
}

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
        zip -q -r "$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}

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
        zip -q -r "$linux_archive" .
    )

    # Windows
    cp -a "$DESKTOP_DIR/output/windows"/. \
        "$windows_tmp/"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$windows_tmp/latest_changelog.md"

    (
        cd "$windows_tmp"
        zip -q -r "$windows_archive" .
    )

    rm -rf "$linux_tmp" "$windows_tmp"

    echo "✔ Created:"
    echo "  $linux_archive"
    echo "  $windows_archive"
}

package_android() {
    local version="$1"

    local archive="$ANDROID_OUTPUT/ironbook-android-v${version}-android-arm64.zip"

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
        zip -q -r "$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}

package_windows_installer() {
    local version="$1"

    local archive="$WINDOWS_INSTALLER_OUTPUT/ironbook-installer-v${version}-win-x64.zip"

    echo "📦 Packaging Windows Installer..."

    mkdir -p "$WINDOWS_INSTALLER_OUTPUT"

    rm -f "$archive"

    local tmp
    tmp="$(mktemp -d)"

    cp "$WINDOWS_INSTALLER_OUTPUT/IronBook-Setup.exe" \
        "$tmp/ironbook_installer.exe"

    cp "$OUTPUT_DIR/latest_changelog.md" \
        "$tmp/latest_changelog.md"

    (
        cd "$tmp"
        zip -q -r "$archive" .
    )

    rm -rf "$tmp"

    echo "✔ Created:"
    echo "  $archive"
}
