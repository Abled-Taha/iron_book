#!/usr/bin/env bash

cmd_exists() {
    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        echo "❌ Required command not found: $command"
        return 1
    fi
}
