#!/bin/bash
# CodexBar KDE Plasma Widget Installer
# Installs: codexbar CLI + Plasma 6 widget

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIDGET_DIR="$(dirname "$SCRIPT_DIR")/com.codexbar.widget"
INSTALL_DIR="${HOME}/.local/bin"
GITHUB_REPO="steipete/CodexBar"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1" >&2; exit 1; }

echo "CodexBar Plasma Widget Installer"
echo "================================="
echo

# Check for Plasma 6
if ! command -v kpackagetool6 &> /dev/null; then
    error "kpackagetool6 not found. This widget requires KDE Plasma 6."
fi

# Check if widget directory exists
if [ ! -d "$WIDGET_DIR" ]; then
    error "Widget directory not found: $WIDGET_DIR"
fi

# Detect architecture
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        *)
            error "Unsupported architecture: $arch (supported: x86_64, aarch64)"
            ;;
    esac
}

# Install codexbar CLI if not present
install_cli() {
    if command -v codexbar &> /dev/null; then
        local version
        version=$(codexbar --version 2>/dev/null | head -1 || echo "unknown")
        success "codexbar CLI already installed: $version"
        return 0
    fi

    info "Installing codexbar CLI..."

    local arch
    arch=$(detect_arch)
    info "Detected architecture: $arch"

    # Get latest version
    local version
    version=$(curl -fsSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" 2>/dev/null | \
        grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        error "Failed to fetch latest release version from GitHub"
    fi
    info "Latest version: $version"

    # Download and extract
    local download_url="https://github.com/${GITHUB_REPO}/releases/download/${version}/CodexBarCLI-${version}-linux-${arch}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT

    info "Downloading from GitHub releases..."
    if ! curl -fsSL "$download_url" -o "${tmp_dir}/codexbar.tar.gz" 2>/dev/null; then
        error "Failed to download CLI from: $download_url"
    fi

    mkdir -p "$INSTALL_DIR"
    tar -xzf "${tmp_dir}/codexbar.tar.gz" -C "$tmp_dir"

    # Find and install binary (may be named codexbar or CodexBarCLI)
    local binary
    binary=$(find "$tmp_dir" -type f -perm -111 \( -name "codexbar" -o -name "CodexBarCLI" \) | head -1)
    if [ -z "$binary" ]; then
        error "Binary not found in archive"
    fi

    mv "$binary" "${INSTALL_DIR}/codexbar"
    chmod +x "${INSTALL_DIR}/codexbar"

    success "CLI installed to ${INSTALL_DIR}/codexbar"

    # Check PATH
    if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
        warn "${INSTALL_DIR} is not in your PATH"
        echo "    Add to ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo
    fi
}

# Install icon to user's icon theme
install_icon() {
    local icon_src="$WIDGET_DIR/contents/icons/codexbar.png"
    local icon_dir="${HOME}/.local/share/icons/hicolor"

    if [ ! -f "$icon_src" ]; then
        warn "Icon file not found: $icon_src"
        return 0
    fi

    info "Installing icon to theme..."

    # Install to multiple sizes for best compatibility
    for size in 128x128 256x256 512x512; do
        mkdir -p "${icon_dir}/${size}/apps"
        cp "$icon_src" "${icon_dir}/${size}/apps/codexbar.png"
    done

    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$icon_dir" 2>/dev/null || true
    fi

    success "Icon installed"
}

# Install Plasma widget
install_widget() {
    # Remove existing installation if present
    if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -q "com.codexbar.widget"; then
        info "Removing existing widget installation..."
        kpackagetool6 -t Plasma/Applet -r com.codexbar.widget 2>/dev/null || true
    fi

    info "Installing Plasma widget..."
    kpackagetool6 -t Plasma/Applet -i "$WIDGET_DIR"
    success "Widget installed"
}

# Main
install_cli
echo
install_icon
echo
install_widget

echo
echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Next steps:"
echo "  1. Authenticate with providers:"
echo "     codexbar auth claude"
echo "     codexbar auth codex"
echo
echo "  2. Add the widget:"
echo "     Right-click desktop/panel → Add Widgets → Search 'CodexBar'"
echo
echo "To uninstall:"
echo "  kpackagetool6 -t Plasma/Applet -r com.codexbar.widget"
echo "  rm ~/.local/bin/codexbar"
echo "  rm ~/.local/share/icons/hicolor/*/apps/codexbar.png"
