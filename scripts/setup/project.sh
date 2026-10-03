#!/usr/bin/env bash

# ==============================================================================
# Project Setup
# ==============================================================================

run_project_setup() {
    echo "🚀 Running project setup tasks..."

    if ! mise run setup; then
        echo "❌ Project setup task failed."
        return 1
    fi
}
