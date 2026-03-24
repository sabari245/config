#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${CONFIG_URL:-https://vorden.dev}"

echo "==> Sabari's dotfiles installer"
echo "==> Source: $BASE_URL"
echo ""

# Cache sudo credentials upfront
sudo -v
# Keep sudo alive in background
(while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &

# Detect distro
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt &>/dev/null; then
    DISTRO="debian"
else
    echo "Error: Only Arch-based and Debian-based systems are supported."
    exit 1
fi

echo "==> Detected: $DISTRO"

# =============================================================================
# Install packages
# =============================================================================

if [ "$DISTRO" = "arch" ]; then
    echo "==> Updating system..."
    sudo pacman -Syu --noconfirm

    echo "==> Installing packages..."
    sudo pacman -S --needed --noconfirm \
        zsh tmux neovim git curl unzip \
        ripgrep zoxide eza fzf dua-cli \
        base-devel

elif [ "$DISTRO" = "debian" ]; then
    echo "==> Updating system..."
    sudo apt update
    sudo apt upgrade -y

    echo "==> Installing packages..."
    sudo apt install -y \
        zsh tmux git curl unzip \
        ripgrep zoxide eza fzf \
        build-essential

    # Neovim - apt version is too old for 0.11+ features, install from release
    echo "==> Installing Neovim (latest stable)..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  NV_ARCH="x86_64" ;;
        aarch64) NV_ARCH="arm64" ;;
        *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    curl -LsSf "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NV_ARCH}.tar.gz" -o /tmp/nvim.tar.gz
    sudo rm -rf /opt/nvim-linux-"${NV_ARCH}"
    sudo tar xzf /tmp/nvim.tar.gz -C /opt/
    sudo ln -sf "/opt/nvim-linux-${NV_ARCH}/bin/nvim" /usr/local/bin/nvim
    rm /tmp/nvim.tar.gz

    # dua-cli (not in apt)
    echo "==> Installing dua-cli..."
    curl -LSfs https://raw.githubusercontent.com/Byron/dua-cli/master/ci/install.sh | \
        sh -s -- --git Byron/dua-cli --target x86_64-unknown-linux-musl --crate dua --tag v2.29.0
fi

# =============================================================================
# Zsh plugins
# =============================================================================

if [ ! -d ~/.zsh/fast-syntax-highlighting ]; then
    echo "==> Installing fast-syntax-highlighting..."
    mkdir -p ~/.zsh
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.zsh/fast-syntax-highlighting
else
    echo "==> fast-syntax-highlighting already installed, pulling latest..."
    git -C ~/.zsh/fast-syntax-highlighting pull
fi

# =============================================================================
# Download and install config files
# =============================================================================

echo "==> Installing config files..."

# Backup existing configs
for f in ~/.zshrc ~/.tmux.conf ~/.config/nvim/init.lua; do
    if [ -f "$f" ]; then
        echo "    Backing up $f → ${f}.bak"
        cp "$f" "${f}.bak"
    fi
done

curl -LsSf "$BASE_URL/.zshrc"   -o ~/.zshrc
curl -LsSf "$BASE_URL/.tmux.conf" -o ~/.tmux.conf

mkdir -p ~/.config/nvim
curl -LsSf "$BASE_URL/init.lua" -o ~/.config/nvim/init.lua

# =============================================================================
# Set zsh as default shell
# =============================================================================

if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "==> Setting zsh as default shell..."
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
fi

# =============================================================================
# Done
# =============================================================================

echo ""
echo "==> All done! Installed:"
echo "    - zsh + fast-syntax-highlighting"
echo "    - tmux"
echo "    - neovim (with lazy.nvim auto-bootstrap)"
echo "    - ripgrep, zoxide, eza, fzf, dua-cli"
echo ""
echo "    Config files placed in:"
echo "    ~/.zshrc"
echo "    ~/.tmux.conf"
echo "    ~/.config/nvim/init.lua"
echo ""
echo "    Restart your shell or run: exec zsh"
