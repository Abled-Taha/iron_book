#!/usr/bin/env bash
set -euo pipefail

source ./scripts/utility.sh

# ==============================================================================
# Configuration
# ==============================================================================

export MISE_DATA_DIR="$(pwd)/.mise"
export MISE_STATE_DIR="$(pwd)/.mise/state"
export MISE_CACHE_DIR="$(pwd)/.mise/cache"

# mise installs to ~/.local/bin by default.
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# Linux Distribution
# ==============================================================================

DISTRO="$(get_linux_distro)"

# ==============================================================================
# Environment Files
# ==============================================================================

copy_env_if_exists() {
    local target_dir="$1"

    if [[ ! -f "$target_dir/.env" && -f "$target_dir/.env.example" ]]; then
        echo "📝 Creating $target_dir/.env"
        cp "$target_dir/.env.example" "$target_dir/.env"
    fi
}

setup_environment_files() {
    echo "📝 Checking environment files..."

    copy_env_if_exists "."
    copy_env_if_exists "./apps/android"
    copy_env_if_exists "./apps/api"
    copy_env_if_exists "./apps/desktop"
    copy_env_if_exists "./apps/home"
    copy_env_if_exists "./apps/web"
}

# ==============================================================================
# System Package Installation
# ==============================================================================

install_system_packages() {
    case "$DISTRO" in
        arch|cachyos|manjaro)
            echo "📦 Installing system dependencies with pacman..."

            sudo pacman -S --needed --noconfirm \
                mingw-w64-gcc \
                docker \
                docker-compose \
                curl \
                git
            ;;

        ubuntu|debian|linuxmint|pop)
            echo "📦 Installing system dependencies with apt..."

            sudo apt-get update

            sudo apt-get install -y \
                gcc-mingw-w64-x86-64 \
                docker.io \
                docker-compose-v2 \
                curl \
                git
            ;;

        fedora)
            echo "📦 Installing system dependencies with dnf..."

            sudo dnf install -y \
                mingw64-gcc \
                docker \
                docker-compose \
                curl \
                git
            ;;

        opensuse-tumbleweed|opensuse-leap)
            echo "📦 Installing system dependencies with zypper..."

            sudo zypper install -y \
                mingw64-cross-gcc \
                docker \
                docker-compose \
                curl \
                git
            ;;

        nixos)
            echo "❌ NixOS is not currently supported."
            exit 1
            ;;

        *)
            echo "❌ Unsupported Linux distribution: $DISTRO"
            echo ""
            echo "Please install these dependencies manually:"
            echo "  - MinGW-w64"
            echo "  - Docker"
            echo "  - Docker Compose"
            echo "  - curl"
            echo "  - git"
            exit 1
            ;;
    esac
}

check_system_commands() {
    local missing=0

    command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1 || missing=1
    command -v docker >/dev/null 2>&1 || missing=1
    command -v curl >/dev/null 2>&1 || missing=1
    command -v git >/dev/null 2>&1 || missing=1

    if ! command -v docker >/dev/null 2>&1 || \
       ! docker compose version >/dev/null 2>&1; then
        missing=1
    fi

    if [[ "$missing" -eq 1 ]]; then
        install_system_packages
    else
        echo "✔ System dependencies already installed."
    fi
}

# ==============================================================================
# MinGW
# ==============================================================================

ensure_mingw() {
    if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
        echo "✔ MinGW-w64 is available."
        return
    fi

    echo "❌ MinGW-w64 installation was unsuccessful."
    echo ""
    echo "Expected command:"
    echo "  x86_64-w64-mingw32-gcc"
    exit 1
}

# ==============================================================================
# Docker
# ==============================================================================

ensure_docker_service() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker is not installed."
        exit 1
    fi

    if docker info >/dev/null 2>&1; then
        echo "✔ Docker daemon is running."
        return
    fi

    echo "⚠ Docker is installed but the daemon is not running."

    if command -v systemctl >/dev/null 2>&1; then
        echo "🚀 Attempting to start Docker..."

        if sudo systemctl enable --now docker; then
            if docker info >/dev/null 2>&1; then
                echo "✔ Docker daemon started."
                return
            fi
        fi
    fi

    echo ""
    echo "❌ Docker daemon could not be started."
    echo ""
    echo "Please start Docker manually and run setup again."
    exit 1
}

ensure_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        echo "✔ Docker Compose is available."
        return
    fi

    echo "❌ Docker Compose is not available."
    echo ""
    echo "Please install the Docker Compose plugin for your distribution."
    exit 1
}

ensure_docker_user_access() {
    # If Docker already works without sudo, nothing needs to be done.
    if docker info >/dev/null 2>&1; then
        return
    fi

    if ! getent group docker >/dev/null 2>&1; then
        echo "⚠ Docker group does not exist."
        return
    fi

    if id -nG "$USER" | tr ' ' '\n' | grep -qx "docker"; then
        echo "❌ Docker is still inaccessible even though $USER belongs to the docker group."
        echo ""
        echo "A new login session may be required."
        echo "Please log out and back in, then run setup again."
        exit 1
    fi

    echo "👤 Adding $USER to the docker group..."

    sudo usermod -aG docker "$USER"

    echo ""
    echo "✔ Added $USER to the docker group."
    echo ""
    echo "⚠ A new login session is required before Docker can be used."
    echo "  Please log out and back in, then run:"
    echo ""
    echo "    ./setup.sh"
    echo ""

    exit 0
}

setup_docker() {
    ensure_docker_service
    ensure_docker_compose
    ensure_docker_user_access
}

# ==============================================================================
# mise
# ==============================================================================

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        echo "✔ mise is already installed."
        return
    fi

    echo "📦 Installing mise..."

    curl https://mise.run | sh

    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v mise >/dev/null 2>&1; then
        echo "❌ mise installation completed, but mise could not be found."
        echo ""
        echo "Expected location:"
        echo "  $HOME/.local/bin/mise"
        exit 1
    fi

    echo "✔ mise installed."
}

setup_mise() {
    install_mise

    echo "📦 Installing project toolchains via mise..."

    mise trust
    mise install
}

# ==============================================================================
# Project Setup
# ==============================================================================

run_project_setup() {
    echo "🚀 Running project setup tasks..."

    if ! mise run setup; then
        echo "❌ Project setup task failed."
        exit 1
    fi
}

# ==============================================================================
# Git Hooks
# ==============================================================================

setup_git_hooks() {
    if command -v pre-commit >/dev/null 2>&1; then
        echo "🔧 Installing pre-commit hooks..."
        pre-commit install
    fi
}

# ==============================================================================
# Main
# ==============================================================================

echo ""
echo "========================================"
echo " IronBook Development Environment Setup"
echo "========================================"
echo ""

echo "🐧 Detected Linux distribution: $DISTRO"

if [[ "$DISTRO" == "nixos" ]]; then
    echo "❌ NixOS is not currently supported."
    exit 1
fi

setup_environment_files

echo ""
echo "🔍 Checking system dependencies..."
check_system_commands

echo ""
echo "🔍 Checking MinGW-w64..."
ensure_mingw

echo ""
echo "🐳 Checking Docker..."
setup_docker

echo ""
echo "🔧 Setting up mise..."
setup_mise

echo ""
run_project_setup

echo ""
setup_git_hooks

echo ""
echo "========================================"
echo " 🎉 Setup complete!"
echo "========================================"
echo ""
echo "Don't forget to copy your Android signing keystore to:"
echo ""
echo "  apps/android/ironbook.keystore"
echo ""
echo "This is required to create a signed Android release."
echo ""
