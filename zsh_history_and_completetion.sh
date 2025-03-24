#!/bin/bash

set -e  # Exit on error

echo "🔹 Mandillah Jr  on the terminal..."
echo "🔹 Automating Zsh setup..."

# Ensure Zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "⚠️ Zsh is not installed. Installing..."
    sudo pacman -S --noconfirm zsh
fi

# Set Zsh as the default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "🔹 Setting Zsh as the default shell..."
    chsh -s $(which zsh)
fi

ZSHRC="$HOME/.zshrc"

# Backup existing .zshrc
if [[ -f "$ZSHRC" ]]; then
    echo "🔹 Backing up existing ~/.zshrc to ~/.zshrc.backup"
    cp "$ZSHRC" "$HOME/.zshrc.backup"
fi

# Write Zsh configuration
echo "🔹 Configuring Zsh settings..."

cat <<EOF > "$ZSHRC"
# Zsh History Settings
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Enable Tab Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' squeeze-slashes true

# Enable Zsh Autosuggestions & Syntax Highlighting
if [[ -d "\$HOME/.zsh/zsh-autosuggestions" ]]; then
    source "\$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -d "\$HOME/.zsh/zsh-syntax-highlighting" ]]; then
    source "\$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Enable Fuzzy Finder (fzf)
if [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
    source "/usr/share/fzf/key-bindings.zsh"
    source "/usr/share/fzf/completion.zsh"
fi
EOF

# Install required packages
echo "🔹 Installing dependencies..."
sudo pacman -S --noconfirm fzf git

# Install Zsh plugins
echo "🔹 Installing Zsh plugins..."
mkdir -p "$HOME/.zsh"

if [[ ! -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
fi

if [[ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"
fi

# Apply changes
echo "🔹 Applying changes..."
source "$ZSHRC"

echo "✅ Zsh setup completed successfully! Restart your terminal for full effect."
