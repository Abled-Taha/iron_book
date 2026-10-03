#!/usr/bin/env bash

update_api_version() {
    local version="$1"

    echo "📦 Updating API version to $version..."

    sed -i -E \
        '0,/^version = "[^"]+"/s//version = "'"$version"'"/' \
        "$API_DIR/Cargo.toml"

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
        "$DESKTOP_DIR/ironbook.csproj"

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
        "$ANDROID_DIR/app/build.gradle.kts"

    sed -i -E \
        's/versionCode = [0-9]+/versionCode = '"$version_code"'/' \
        "$ANDROID_DIR/app/build.gradle.kts"

    echo "✔ Android version updated."
}

update_windows_installer_version() {
    local version="$1"

    echo "📦 Updating Windows installer version to $version..."

    sed -i -E \
        's|^AppVersion=.*$|AppVersion='"$version"'|' \
        "$SCRIPTS_DIR/install/windows/installer.iss"

    echo "✔ Windows installer version updated."
}

update_web_version() {
    local version="$1"

    echo "📦 Updating Web version to $version..."

    sed -i -E \
        's|^version = ".*"$|version = "'"$version"'"|' \
        "apps/web/pyproject.toml"

    echo "✔ Web version updated."
}


update_changelog_version() {
    local version="$1"
    local changelog="$ROOT_DIR/.github/docs/CHANGELOG.md"
    local date="$(date +%Y-%m-%d)"

    echo "📦 Updating changelog to $version ($date)..."

    if grep -q '^## \[Unreleased\]$' "$changelog"; then
        sed -i \
            "/^## \[Unreleased\]$/s//## [$version] $date/" \
            "$changelog"

        echo "✔ Changelog updated."
    else
        echo "⚠ No [Unreleased] section found. Skipping changelog update."
    fi
}
