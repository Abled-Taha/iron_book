#!/usr/bin/env bash

# ==============================================================================
# Environment Files
# ==============================================================================

copy_env_if_exists() {
    local target_dir="$1"

    if [[ ! -d "$target_dir" ]]; then
        return 0
    fi

    if [[ ! -f "$target_dir/.env" && -f "$target_dir/.env.example" ]]; then
        echo "📝 Creating $target_dir/.env"
        cp -- "$target_dir/.env.example" "$target_dir/.env"
    fi
}

setup_environment_files() {
    echo "📝 Checking environment files..."

    copy_env_if_exists "$ROOT_DIR"
    copy_env_if_exists "$ANDROID_DIR"
    copy_env_if_exists "$API_DIR"
    copy_env_if_exists "$DESKTOP_DIR"
    copy_env_if_exists "$HOME_DIR"
    copy_env_if_exists "$WEB_DIR"
}
