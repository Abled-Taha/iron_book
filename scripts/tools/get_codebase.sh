#!/usr/bin/env bash


cmd_get_codebase() {
    local output_file="codebase.txt"

    echo "=== DIRECTORY TREE ===" > "$output_file"

    tree -a \
        -I "node_modules|build|dist|target|.git|.env|__pycache__|.next|.cache|.gradle|.venv|.idea|.android_sdk|.mise|$output_file" \
        >> "$output_file"

    echo -e "\n=== FILE CONTENTS ===" >> "$output_file"

    find . \
        -type d \( \
            -name "node_modules" -o \
            -name "build" -o \
            -name "dist" -o \
            -name "target" -o \
            -name ".git" -o \
            -name "__pycache__" -o \
            -name ".next" -o \
            -name ".cache" -o \
            -name ".gradle" -o \
            -name ".venv" -o \
            -name ".idea" -o \
            -name ".android_sdk" -o \
            -name ".mise" \
        \) -prune -o \
        -type f -print0 |
    while IFS= read -r -d '' file; do

        local clean_file="${file#./}"

        # Don't include the generated output file itself
        [[ "$clean_file" == "$output_file" ]] && continue

        case "$clean_file" in
            *pnpm-lock.yaml|*package-lock.json|*yarn.lock|*uv.lock|*Cargo.lock|*poetry.lock|*.DS_Store)
                continue
                ;;
            *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.webp)
                continue
                ;;
            *.pdf|*.zip|*.tar.gz|*.rar|*.bin|*.exe|*.so|*.dll|*.dylib|*.jar|*.lock)
                continue
                ;;
            *.env|*.env.*)
                continue
                ;;
        esac

        # Skip files ignored by git
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if git check-ignore -q -- "$clean_file"; then
                continue
            fi
        fi

        echo -e "\n==> $clean_file <==" >> "$output_file"
        cat -- "$file" >> "$output_file"

    done

    echo "✔ Codebase successfully compiled to $output_file."
}
