#!/usr/bin/env bash

cmd_get_codebase() {
    local output_file="codebase.txt"
    local max_file_size=$((5 * 1024 * 1024)) # 5 MiB
    local root_dir
    local output_path
    local git_root=""
    local in_git_repo=false
    local failed=0
    local count=0

    # ------------------------------------------------------------
    # Determine repository root.
    # If we're inside a Git repository, operate from its root.
    # Otherwise, operate from the current directory.
    # ------------------------------------------------------------
    if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
        root_dir="$git_root"
        in_git_repo=true
    else
        root_dir="$(pwd -P)" || {
            printf 'Error: unable to determine current directory.\n' >&2
            return 1
        }
    fi

    # ------------------------------------------------------------
    # Convert output filename to an absolute path.
    # ------------------------------------------------------------
    if [[ "$output_file" = /* ]]; then
        output_path="$output_file"
    else
        output_path="$root_dir/$output_file"
    fi

    # ------------------------------------------------------------
    # Always start with a fresh output file.
    # ------------------------------------------------------------
    if ! : > "$output_path"; then
        printf 'Error: cannot create %s\n' "$output_path" >&2
        return 1
    fi

    # ------------------------------------------------------------
    # Work from repository root so all paths have consistent
    # semantics for both find and git.
    # ------------------------------------------------------------
    if ! cd -- "$root_dir"; then
        printf 'Error: cannot enter %s\n' "$root_dir" >&2
        return 1
    fi

    # ------------------------------------------------------------
    # Find candidate files.
    # ------------------------------------------------------------
    while IFS= read -r -d '' file; do
        local clean_file="${file#./}"
        local absolute_file="$root_dir/$clean_file"
        local file_size
        local mime_type
        local is_binary=false

        # --------------------------------------------------------
        # Never include our own generated output.
        # --------------------------------------------------------
        if [[ "$absolute_file" == "$output_path" ]]; then
            continue
        fi

        # --------------------------------------------------------
        # Skip Git-ignored files.
        # --------------------------------------------------------
        if "$in_git_repo" && git check-ignore -q -- "$clean_file"; then
            continue
        fi

        # --------------------------------------------------------
        # Skip sensitive files.
        # --------------------------------------------------------
        case "$clean_file" in
            .env|.env.*|*/.env|*/.env.*|\
            *.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|\
            */id_rsa|*/id_dsa|*/id_ecdsa|*/id_ed25519|\
            */credentials.json|*/service-account.json)
                continue
                ;;
        esac

        # --------------------------------------------------------
        # Skip dependency lockfiles and OS metadata.
        # --------------------------------------------------------
        case "$clean_file" in
            pnpm-lock.yaml|*/pnpm-lock.yaml|\
            package-lock.json|*/package-lock.json|\
            yarn.lock|*/yarn.lock|\
            bun.lock|*/bun.lock|\
            uv.lock|*/uv.lock|\
            Cargo.lock|*/Cargo.lock|\
            poetry.lock|*/poetry.lock|\
            Pipfile.lock|*/Pipfile.lock|\
            composer.lock|*/composer.lock|\
            Gemfile.lock|*/Gemfile.lock|\
            .DS_Store|*/.DS_Store)
                continue
                ;;
        esac

        # --------------------------------------------------------
        # Skip known binary/media/archive formats immediately.
        # --------------------------------------------------------
        case "$clean_file" in
            *.png|*.jpg|*.jpeg|*.gif|*.bmp|*.tif|*.tiff|*.ico|*.svg|\
            *.webp|*.avif|\
            *.mp3|*.wav|*.flac|*.ogg|*.m4a|\
            *.mp4|*.mov|*.avi|*.mkv|*.webm|\
            *.zip|*.tar|*.gz|*.bz2|*.xz|*.7z|*.rar|\
            *.exe|*.dll|*.so|*.dylib|*.bin|*.o|*.a|\
            *.class|*.pyc|*.wasm|\
            *.woff|*.woff2|*.ttf|*.otf|\
            *.pdf)
                continue
                ;;
        esac

        # --------------------------------------------------------
        # Verify that the path is a regular file.
        # --------------------------------------------------------
        if [[ ! -f "$file" ]]; then
            continue
        fi

        # --------------------------------------------------------
        # Skip very large files.
        # --------------------------------------------------------
        if ! file_size="$(wc -c < "$file")"; then
            printf 'Warning: cannot determine size of %s\n' \
                "$clean_file" >&2
            failed=1
            continue
        fi

        if (( file_size > max_file_size )); then
            printf 'Skipping large file: %s (%s bytes)\n' \
                "$clean_file" "$file_size" >&2
            continue
        fi

        # --------------------------------------------------------
        # Detect binary content.
        #
        # `grep -Iq .` returns success for text and failure for
        # binary data. This avoids relying on MIME database
        # availability or MIME naming conventions.
        # --------------------------------------------------------
        if ! LC_ALL=C grep -Iq . "$file" 2>/dev/null; then
            is_binary=true
        fi

        if [[ "$is_binary" == true ]]; then
            continue
        fi

        # --------------------------------------------------------
        # Write file header.
        # --------------------------------------------------------
        if ! printf '\n==> %s <==\n' "$clean_file" >> "$output_path"; then
            printf 'Error: failed writing header for %s\n' \
                "$clean_file" >&2
            failed=1
            continue
        fi

        # --------------------------------------------------------
        # Copy contents.
        # --------------------------------------------------------
        if ! cat -- "$file" >> "$output_path"; then
            printf 'Error: failed reading %s\n' "$clean_file" >&2
            failed=1
            continue
        fi

        # --------------------------------------------------------
        # Guarantee separation between files, even if the source
        # file doesn't end with a newline.
        # --------------------------------------------------------
        if ! printf '\n' >> "$output_path"; then
            printf 'Error: failed finalizing %s\n' "$clean_file" >&2
            failed=1
            continue
        fi

        # IMPORTANT:
        # Do not use ((count++)) here when the caller may have
        # `set -e` enabled. The first evaluation returns status 1.
        count=$((count + 1))

    done < <(
        find . \
            -type d \( \
                -name .git -o \
                -name node_modules -o \
                -name build -o \
                -name dist -o \
                -name target -o \
                -name __pycache__ -o \
                -name .pytest_cache -o \
                -name .mypy_cache -o \
                -name .ruff_cache -o \
                -name .next -o \
                -name .nuxt -o \
                -name .cache -o \
                -name .gradle -o \
                -name .venv -o \
                -name venv -o \
                -name .idea -o \
                -name .vscode -o \
                -name .terraform -o \
                -name .mise \
            \) -prune -o \
            -type f -print0
    )

    # ------------------------------------------------------------
    # Final status.
    # ------------------------------------------------------------
    if (( failed != 0 )); then
        printf '⚠ Codebase compiled with errors: %d files included in %s\n' \
            "$count" "$output_path" >&2
        return 1
    fi

    printf '✔ Codebase compiled successfully: %d files -> %s\n' \
        "$count" "$output_path"

    return 0
}
