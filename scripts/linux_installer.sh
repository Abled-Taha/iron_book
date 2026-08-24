#!/usr/bin/env sh
set -eu

REPO="Abled-Taha/iron_book"
EXTENSION="zip"

# Embedded GPG Public Key
PUBKEY=$(cat << 'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEaotEixYJKwYBBAHaRw8BAQdAsb6OfXUDsCUVNGO2HpZMZj9NRXTMZvtGIs1Z
l8j3gtC0IEFibGVkLVRhaGEgPGFibGVkdGFoYUBnbWFpbC5jb20+iJAEExYKADgW
IQQ7EUhWFbLtuuXjIJAJlsVXaepcJwUCaotEiwIbAwULCQgHAgYVCgkICwIEFgID
AQIeAQIXgAAKCRAJlsVXaepcJ/78APoC8PG9EiLiSLC8kImz0umqZ0fkRivQs9g5
t61/EvrVowEA8efu0QK8MM6LrXkn61vT5yuZRVoErpuU6LA6+s1ggwm4OARqi0SL
EgorBgEEAZdVAQUBAQdAc4SEQjnfafFjvGKhuW4fGVbT6Q3/0d3FSoRvy0TY2hcD
AQgHiHgEGBYKACAWIQQ7EUhWFbLtuuXjIJAJlsVXaepcJwUCaotEiwIbDAAKCRAJ
lsVXaepcJ4KnAP4kiCaQoEMaZGJExpf9N8RLH6ewf1ytPvZijiqvMgVTAQEA+bCr
vOtAPzTqTIg5BP8jqXXbWI8KAn7Y0YlqCP48CA4=
=mh7+
-----END PGP PUBLIC KEY BLOCK-----
EOF
)

# Prerequisites check
for cmd in curl jq gpg unzip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' is not installed." >&2
    exit 1
  fi
done

# 1. Prompt release channel
printf "Select release type ([s]table / [p]re-release): "
read -r RELEASE_CHOICE < /dev/tty

case "$RELEASE_CHOICE" in
  [pP]*)
    API_URL="https://api.github.com/repos/${REPO}/releases"
    IS_LIST=true
    ;;
  *)
    API_URL="https://api.github.com/repos/${REPO}/releases/latest"
    IS_LIST=false
    ;;
esac

echo "Fetching release metadata..."
API_RESPONSE=$(curl -sSL "$API_URL")

if [ "$IS_LIST" = true ]; then
  ASSETS_JSON=$(echo "$API_RESPONSE" | jq -r '.[0].assets // empty')
else
  ASSETS_JSON=$(echo "$API_RESPONSE" | jq -r '.assets // empty')
fi

if [ -z "$ASSETS_JSON" ] || [ "$ASSETS_JSON" = "null" ]; then
  echo "Error: Could not retrieve release assets from GitHub API." >&2
  exit 1
fi

ZIP_URL=$(echo "$ASSETS_JSON" | jq -r ".[] | select(.name | endswith(\".${EXTENSION}\")) | .browser_download_url" | head -n 1)
ASC_URL=$(echo "$ASSETS_JSON" | jq -r '.[] | select(.name | endswith(".asc")) | .browser_download_url' | head -n 1)

if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" = "null" ]; then
  echo "Error: Release asset matching .${EXTENSION} was not found." >&2
  exit 1
fi

if [ -z "$ASC_URL" ] || [ "$ASC_URL" = "null" ]; then
  echo "Error: Release signature (.asc) was not found." >&2
  exit 1
fi

# 2. Setup temporary workspace
TMP_DIR=$(mktemp -d)
GNUPGHOME=$(mktemp -d)
export GNUPGHOME
chmod 700 "$GNUPGHOME"

cleanup() {
  rm -rf "$TMP_DIR" "$GNUPGHOME"
}
trap cleanup EXIT INT TERM

ZIP_FILE="${TMP_DIR}/ironbook.${EXTENSION}"
ASC_FILE="${TMP_DIR}/ironbook.${EXTENSION}.asc"
KEY_FILE="${TMP_DIR}/pubkey.asc"

# 3. Download release files
echo "Downloading archive..."
curl -sSL -o "$ZIP_FILE" "$ZIP_URL"

echo "Downloading signature..."
curl -sSL -o "$ASC_FILE" "$ASC_URL"

# 4. GPG Verification
echo "$PUBKEY" > "$KEY_FILE"
gpg --quiet --batch --import "$KEY_FILE"

echo "Verifying GPG signature..."
if gpg --quiet --batch --verify "$ASC_FILE" "$ZIP_FILE"; then
  echo "Signature verification successful!"
else
  echo "Error: GPG signature verification failed! Aborting." >&2
  exit 1
fi

# 5. Extraction & Path Setup
TARGET_SHARE="${HOME}/.local/share/ironbook"
TARGET_BIN="${HOME}/.local/bin"
TARGET_APPS="${HOME}/.local/share/applications"

mkdir -p "$TARGET_BIN" "$TARGET_APPS" "${HOME}/.local/share"

echo "Extracting application..."
rm -rf "$TARGET_SHARE"
mkdir -p "$TARGET_SHARE"
unzip -q "$ZIP_FILE" -d "$TMP_DIR/extracted"

# Handle top-level directory flattening inside zip if necessary
EXTRACTED_CONTENT=$(ls -A "$TMP_DIR/extracted")
if [ $(echo "$EXTRACTED_CONTENT" | wc -l) -eq 1 ] && [ -d "$TMP_DIR/extracted/$EXTRACTED_CONTENT" ]; then
  mv "$TMP_DIR/extracted/$EXTRACTED_CONTENT"/* "$TARGET_SHARE/"
else
  mv "$TMP_DIR/extracted"/* "$TARGET_SHARE/"
fi

# Ensure main binary is executable
chmod +x "${TARGET_SHARE}/ironbook"

# 6. Generate embedded Uninstaller inside ~/.local/share/ironbook/
echo "Embedding uninstaller..."
cat << 'EOF' > "${TARGET_SHARE}/uninstall.sh"
#!/usr/bin/env sh
set -eu

TARGET_SHARE="${HOME}/.local/share/ironbook"
TARGET_BIN="${HOME}/.local/bin/ironbook"
TARGET_DESKTOP="${HOME}/.local/share/applications/ironbook.desktop"

CONFIG_DIR="${HOME}/.config/ironbook"
DATA_DIR="${HOME}/.local/share/ironbook_data"

echo "Uninstalling Iron Book..."

if [ -f "$TARGET_BIN" ]; then
  rm -f "$TARGET_BIN"
  echo "Removed wrapper script: ${TARGET_BIN}"
fi

if [ -f "$TARGET_DESKTOP" ]; then
  rm -f "$TARGET_DESKTOP"
  echo "Removed desktop entry: ${TARGET_DESKTOP}"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
fi

printf "\nDo you also want to remove persistent app configuration and user databases? [y/N]: "
read -r REMOVE_DATA

case "$REMOVE_DATA" in
  [yY]*)
    [ -d "$CONFIG_DIR" ] && rm -rf "$CONFIG_DIR" && echo "Removed ${CONFIG_DIR}"
    [ -d "$DATA_DIR" ] && rm -rf "$DATA_DIR" && echo "Removed ${DATA_DIR}"
    echo "App data purged."
    ;;
  *)
    echo "App configuration and user data retained."
    ;;
esac

if [ -d "$TARGET_SHARE" ]; then
  rm -rf "$TARGET_SHARE"
  echo "Removed app binaries: ${TARGET_SHARE}"
fi

echo "Iron Book has been successfully uninstalled."
EOF
chmod +x "${TARGET_SHARE}/uninstall.sh"

# 7. Wrapper script with --uninstall check
echo "Creating launcher wrapper in ${TARGET_BIN}/ironbook..."
cat << 'EOF' > "${TARGET_BIN}/ironbook"
#!/usr/bin/env sh
if [ "${1:-}" = "--uninstall" ]; then
  exec "${HOME}/.local/share/ironbook/uninstall.sh"
fi

exec "${HOME}/.local/share/ironbook/ironbook" "$@"
EOF
chmod +x "${TARGET_BIN}/ironbook"

# 8. Desktop Entry generation
echo "Creating desktop shortcut..."
cat << EOF > "${TARGET_APPS}/ironbook.desktop"
[Desktop Entry]
Type=Application
Name=IronBook
Comment=The Financial Ledger you need
Exec=${TARGET_BIN}/ironbook
Path=${TARGET_SHARE}
Icon=${TARGET_SHARE}/icon.png
Terminal=false
Categories=Utility;
EOF

echo "Installation complete!"
