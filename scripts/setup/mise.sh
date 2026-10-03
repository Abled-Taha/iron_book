#!/usr/bin/env bash

# ==============================================================================
# mise
# ==============================================================================

install_mise() {
    if cmd_exists mise; then
        echo "✔ mise is already installed."
        return 0
    fi

    echo "📦 Installing mise..."

    curl https://mise.run | sh

    export PATH="$HOME/.local/bin:$PATH"

    if ! cmd_exists mise; then
        echo "❌ mise installation completed, but mise could not be found."
        echo ""
        echo "Expected location:"
        echo "  $HOME/.local/bin/mise"
        return 1
    fi

    echo "✔ mise installed."
}

setup_mise() {
    install_mise

    echo "📦 Installing project toolchains via mise..."

    mise trust
    mise install
}
