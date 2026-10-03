#!/usr/bin/env bash

# ==============================================================================
# Git Hooks
# ==============================================================================

setup_git_hooks() {
    if ! cmd_exists pre-commit; then
        return 0
    fi

    echo "🔧 Installing pre-commit hooks..."
    pre-commit install
}
