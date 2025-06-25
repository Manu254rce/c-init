#!/bin/bash

# C Project Generator - Global Installer
# This script installs the C project generator globally on your system

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/yourusername/c-project-generator/main"
INSTALL_DIR="/usr/local/bin"
COMMAND_NAME="c-init"
SCRIPT_URL="${REPO_URL}/setup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root/sudo for global install
check_permissions() {
    if [[ $EUID -ne 0 ]] && [[ ! -w "$INSTALL_DIR" ]]; then
        print_error "This script needs to install to $INSTALL_DIR"
        print_info "Please run with sudo: curl -fsSL ... | sudo bash"
        print_info "Or run without sudo to install to ~/.local/bin (user-only)"
        
        read -p "Install to ~/.local/bin instead? [y/N]: " user_install
        if [[ "$user_install" =~ ^[Yy]$ ]]; then
            INSTALL_DIR="$HOME/.local/bin"
            mkdir -p "$INSTALL_DIR"
            
            # Check if ~/.local/bin is in PATH
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                print_warning "~/.local/bin is not in your PATH"
                print_info "Add this line to your ~/.bashrc or ~/.zshrc:"
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
                print_info "Then run: source ~/.bashrc (or restart your terminal)"
            fi
        else
            exit 1
        fi
    fi
}

# Download and install the script
install_script() {
    print_info "Downloading C project generator..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$SCRIPT_URL" -o "${INSTALL_DIR}/${COMMAND_NAME}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$SCRIPT_URL" -O "${INSTALL_DIR}/${COMMAND_NAME}"
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    
    # Make executable
    chmod +x "${INSTALL_DIR}/${COMMAND_NAME}"
    
    print_success "Installed to ${INSTALL_DIR}/${COMMAND_NAME}"
}

# Verify installation
verify_installation() {
    if [[ -x "${INSTALL_DIR}/${COMMAND_NAME}" ]]; then
        print_success "Installation successful!"
        print_info "You can now use: ${COMMAND_NAME}"
        
        # Test if command is accessible
        if command -v "$COMMAND_NAME" >/dev/null 2>&1; then
            print_success "Command '$COMMAND_NAME' is ready to use"
        else
            print_warning "Command '$COMMAND_NAME' is installed but not found in PATH"
            print_info "Make sure $INSTALL_DIR is in your PATH environment variable"
        fi
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Main installation process
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              C Project Generator - Installer                 ║"
    echo "║                                                              ║"
    echo "║  This will install the C project generator globally so       ║"
    echo "║  you can use 'c-init' command from anywhere.                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    check_permissions
    install_script
    verify_installation
    
    echo
    print_info "Usage examples:"
    echo "  ${COMMAND_NAME}              # Interactive setup in current directory"
    echo "  ${COMMAND_NAME} --help       # Show help information"
    echo "  ${COMMAND_NAME} --version    # Show version information"
    echo
    print_info "To uninstall: sudo rm ${INSTALL_DIR}/${COMMAND_NAME}"
    print_success "Happy coding! 🚀"
}

main "$@"
