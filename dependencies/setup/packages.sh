#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Package lists
XORG=(
    "xorg"
)

I3WM=(
    "i3"
)

TERMINAL=(
    "kitty"
)

UTILITIES=(
    "ranger"
    "dolphin"
)

APPS=(
    "firefox"
)

FONTS=(
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"
    "ttf-bitstream-vera"
    "ttf-dejavu"
    "ttf-liberation"
    "ttf-opensans"
)

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to install packages
install_packages() {
    local category=$1
    shift
    local packages=("$@")
    
    print_msg "Installing $category packages..."
    
    for package in "${packages[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            print_warning "$package is already installed"
        else
            print_msg "Installing $package..."
            sudo pacman -S --noconfirm "$package"
            
            if [ $? -eq 0 ]; then
                print_msg "$package installed successfully"
            else
                print_error "Failed to install $package"
            fi
        fi
    done
}

# Update system first
print_msg "Updating system..."
sudo pacman -Syu --noconfirm

# Install package groups
install_packages "Xorg" "${XORG[@]}"
install_packages "i3wm" "${I3WM[@]}"
install_packages "Terminal" "${TERMINAL[@]}"
install_packages "Utilities" "${UTILITIES[@]}"
install_packages "Applications" "${APPS[@]}"
install_packages "Fonts" "${FONTS[@]}"

print_msg "Package installation complete!"
print_warning "Please reboot your system for all changes to take effect"