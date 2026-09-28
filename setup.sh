#!/bin/sh

. ./scripts/utility.sh

get_linux_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    if command -v lsb_release >/dev/null 2>&1; then
      lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
      echo "unknown"
    fi
  fi
}

DISTRO=$(get_linux_distro)

# Safely handle the .env creation so it doesn't overwrite an existing file

if [ ! -f "$target_dir/.env" ] && [ -f "$target_dir/.env.example" ]; then
    cp "$target_dir/.env.example" "$target_dir/.env"
fi

copy_env_if_exists "."
copy_env_if_exists "./apps/android"
copy_env_if_exists "./apps/api"
copy_env_if_exists "./apps/desktop"
copy_env_if_exists "./apps/home"
copy_env_if_exists "./apps/web"

case "$DISTRO" in
nixos)
  echo "❌ Error: Running on NixOS, which is not currently supported. EXITING."
  exit 1
  ;;

*)
  echo "🐧 Running on Linux"
  cmd_exists mise || exit 1
  cmd_exists docker compose || exit 1

  echo "📦 Installing toolchains via mise..."
  export MISE_DATA_DIR="$(pwd)/.mise"
  export MISE_STATE_DIR="$(pwd)/.mise/state"
  export MISE_CACHE_DIR="$(pwd)/.mise/cache"
  mise trust && mise install || {
    echo "❌ Error: 'mise install' failed."
    exit 1
  }

  echo "🚀 Running project setup tasks..."
  mise run setup || {
    echo "❌ Error: Project setup task failed."
    exit 1
  }

  if cmd_exists pre-commit; then
    pre-commit install
  fi

  echo '🎉 All setup complete!'
  exit 0
  ;;
esac
