#!/bin/bash

cmd_exists() {
    # $1 represents the first argument passed to this function
    if ! command -v "$1" &> /dev/null; then
        echo "❌ Error: $1 is not installed."
        return 1
    fi
}
