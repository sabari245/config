# dotfiles

Portable zsh + tmux + neovim config for Debian and Arch-based systems.

## Install

```sh
curl -LsSf https://vorden.dev/install.sh | sh
```

## What's included

| File | Description |
|------|-------------|
| `.zshrc` | Zsh config with history, completions, prompt, zoxide, fzf, eza |
| `.tmux.conf` | Tmux config with vi mode, blue theme, mouse support |
| `init.lua` | Neovim config with lazy.nvim, telescope, treesitter, LSP, completion |

## Packages installed

**Both distros:** zsh, tmux, neovim, git, curl, ripgrep, zoxide, eza, fzf, dua-cli

Neovim is installed from the latest GitHub release on Debian (apt version is too old for 0.11+ features).
