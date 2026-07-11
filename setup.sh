#!/bin/sh

source ./scripts/utility.sh

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

# 1. Safely handle the .env creation so it doesn't overwrite an existing file
if [ ! -f ./apps/web/.env ]; then
  cp ./apps/web/.env.example ./apps/web/.env
fi
if [ ! -f ./apps/api/.env ]; then
  cp ./apps/api/.env.example ./apps/api/.env
fi

read -n 1 -r -s -p "Kindly verify the entries in ./apps/web/.env, then press any key to continue." key
echo ""
read -n 1 -r -s -p "Kindly verify the entries in ./apps/api/.env, then press any key to continue." key
echo ""

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

  echo '🎉 All setup complete!'
  exit 0
  ;;
esac
