#!/bin/sh

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

cmd_exists() {
  command -v -- "$1" >/dev/null 2>&1
}

DISTRO=$(get_linux_distro)

# 1. Safely handle the .env creation so it doesn't overwrite an existing file
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Note: Removed the '$' from $"Kindly..." as it's a bash-ism that causes syntax warnings in standard sh
read -n 1 -r -s -p "Kindly verify the entries in '.env' file in the project directory, then press any key to continue." key
echo ""

case "$DISTRO" in
nixos)
  echo "❌ Error: Running on NixOS, which is not currently supported. EXITING."
  exit 1 # Exit with an error code instead of 0 since it didn't complete setup
  ;;
*)
  echo "🐧 Running on Linux"
  if cmd_exists mise; then
    echo "✔ 'mise' is available. Proceeding..."
  else
    echo "❌ Error: 'mise' is not installed. Please install it to continue." >&2
    exit 1
  fi

  echo "📦 Installing toolchains via mise..."
  export MISE_DATA_DIR = "$(pwd)/.mise"
  export MISE_CACHE_DIR = "$(pwd)/.mise/cache"
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

