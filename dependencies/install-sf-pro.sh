#!/bin/bash

# Configuration
SOURCE="SF-Pro.dmg"
INSTALL_DIR="/usr/share/fonts/apple"
WORK_DIR="SF-Pro"

if [[ $EUID -eq 0 ]]; then
    echo ":: Warning: It's recommended to run this script as a regular user."
    echo ":: The script will request root privileges only when needed."
fi

# Dependencies check
DEPS=("7zip" "libarchive")
for dep in "${DEPS[@]}"; do
    if ! pacman -Qi "$dep" &>/dev/null; then
        echo ":: Missing dependency: $dep"
        echo ":: Please install with: sudo pacman -S $dep"
        exit 1
    fi
done

echo ":: Installing SF-Pro fonts..."
echo ":: Extracting $SOURCE..."

7z x "$SOURCE" -o"$WORK_DIR" >/dev/null 2>&1 || {
    echo ":: Extraction failed!"
    exit 1
}

echo ":: Preparing package files..."

bsdtar -xf "$WORK_DIR/SFProFonts/SF Pro Fonts.pkg" -C "$WORK_DIR" >/dev/null 2>&1
bsdtar -xf "$WORK_DIR/SFProFonts.pkg/Payload" -C "$WORK_DIR" >/dev/null 2>&1

echo ":: Installing fonts to $INSTALL_DIR..."

sudo install -dm755 "$INSTALL_DIR"
sudo install -m644 "$WORK_DIR/Library/Fonts/"*.ttf "$INSTALL_DIR/"
sudo install -m644 "$WORK_DIR/Library/Fonts/"*.otf "$INSTALL_DIR/"

echo ":: Updating font cache..."

sudo fc-cache -fv >/dev/null 2>&1

echo ":: SF-Pro fonts installed successfully."
