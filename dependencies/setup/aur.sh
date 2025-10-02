#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

AUR_HELPER="yay"

# AUR packages
AUR_PACKAGES=(
    "twmn-git"
    "apple-fonts"
)

# Print functions
print_msg() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Do not run this script as root!"
        exit 1
    fi
}

# Install AUR helper
install_aur_helper() {
    if command -v "$AUR_HELPER" &> /dev/null; then
        print_warning "$AUR_HELPER is already installed"
        return 0
    fi
    
    print_msg "Installing $AUR_HELPER..."
    
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit 1
    
    # Clone AUR helper repo
    case $AUR_HELPER in
        yay)
            git clone https://aur.archlinux.org/yay.git
            cd yay || exit 1
            ;;
        paru)
            git clone https://aur.archlinux.org/paru.git
            cd paru || exit 1
            ;;
        *)
            print_error "Unknown AUR helper: $AUR_HELPER"
            exit 1
            ;;
    esac
    
    # Build and install
    makepkg -si --noconfirm
    
    if [ $? -eq 0 ]; then
        print_msg "$AUR_HELPER installed successfully"
        cd - > /dev/null
        rm -rf "$TMP_DIR"
        return 0
    else
        print_error "Failed to install $AUR_HELPER"
        cd - > /dev/null
        rm -rf "$TMP_DIR"
        exit 1
    fi
}

# Check if package is installed
is_installed() {
    if pacman -Qi "$1" &> /dev/null || $AUR_HELPER -Qi "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install AUR packages
install_aur_packages() {
    print_msg "Installing AUR packages..."
    
    local failed_packages=()
    
    for package in "${AUR_PACKAGES[@]}"; do
        # Skip commented packages
        [[ "$package" =~ ^#.*$ ]] && continue
        
        if is_installed "$package"; then
            print_warning "$package is already installed"
            continue
        fi
        
        print_msg "Installing $package..."
        $AUR_HELPER -S --noconfirm "$package"
        
        if [ $? -eq 0 ]; then
            print_msg "$package installed successfully"
        else
            print_error "Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    # Report failed packages
    if [ ${#failed_packages[@]} -gt 0 ]; then
        print_warning "The following packages failed to install:"
        for pkg in "${failed_packages[@]}"; do
            echo "  - $pkg"
        done
        return 1
    fi
    
    return 0
}

# Update AUR packages
update_aur_packages() {
    print_msg "Updating AUR packages..."
    $AUR_HELPER -Syu --noconfirm
}

# Interactive package selection
interactive_mode() {
    print_info "Available AUR packages:"
    for i in "${!AUR_PACKAGES[@]}"; do
        echo "  $((i+1))) ${AUR_PACKAGES[$i]}"
    done
    
    echo ""
    read -p "Install all packages? (y/n): " install_all
    
    if [[ "$install_all" =~ ^[Yy]$ ]]; then
        install_aur_packages
    else
        read -p "Enter package numbers to install (e.g., 1 3 5): " selection
        
        local selected_packages=()
        for num in $selection; do
            idx=$((num-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#AUR_PACKAGES[@]} ]; then
                selected_packages+=("${AUR_PACKAGES[$idx]}")
            fi
        done
        
        # Temporarily replace package list
        local original_packages=("${AUR_PACKAGES[@]}")
        AUR_PACKAGES=("${selected_packages[@]}")
        install_aur_packages
        AUR_PACKAGES=("${original_packages[@]}")
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -i, --install       Install all AUR packages
    -u, --update        Update AUR packages
    -h, --helper-only   Install only the AUR helper
    -s, --select        Interactive package selection
    --help              Show this help message

Examples:
    $0 -i               Install AUR helper and all packages
    $0 -h               Install only AUR helper
    $0 -s               Interactive mode
    $0 -u               Update AUR packages
EOF
    exit 0
}

# Main script
main() {
    check_root
    
    # Parse command line arguments
    case "${1:-}" in
        -i|--install)
            install_aur_helper
            install_aur_packages
            ;;
        -u|--update)
            update_aur_packages
            ;;
        -h|--helper-only)
            install_aur_helper
            ;;
        -s|--select)
            install_aur_helper
            interactive_mode
            ;;
        --help)
            show_help
            ;;
        *)
            # Default behavior: install helper and all packages
            print_info "Installing AUR helper and packages..."
            print_info "Use --help for more options"
            echo ""
            install_aur_helper
            install_aur_packages
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_msg "AUR setup complete!"
    else
        print_error "AUR setup completed with errors"
        exit 1
    fi
}

# Run main function
main "$@"