# dotfiles

This repo contains the configuration to setup my machines. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install.

This automated setup supports macOS, Ubuntu, and Fedora Linux distributions.

## How to run

```shell
# SSH Authentication
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --ssh

# Or with Github Token
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

## What gets installed

### Initial Setup
1. **Homebrew** - Package manager for all platforms
2. **Ansible** - Configuration management tool
3. **Automated playbook execution** - Installs and configures software

### Software Stack
- **Shell**: Fish shell with Starship prompt
- **Terminal**: Ghostty (Mac), system terminal (Linux) 
- **Editor**: Neovim with VS Code
- **Development Tools**: Git, Docker, UV (Python), Just, JQ
- **System Tools**: Bat, Eza, Fd, Ripgrep, Zoxide, Dust, Duf
- **Media Tools**: FFmpeg, Gallery-dl, Yt-dlp
- **Networking**: Curlie, HTTPie, Doggo, Gping
- **Fonts**: Nerd Font variants (Mac only)

### Configuration Files
- **Git**: Delta diff viewer, improved merge conflicts
- **Tmux**: Catppuccin theme, custom key bindings
- **Fish**: Completions for CLI tools, custom functions
- **Starship**: Cross-shell prompt configuration
- **Bat**: Catppuccin Mocha theme

## Directory Structure

```
├── dot_bootstrap/           # Ansible playbooks
│   ├── setup-mac.yml       # macOS software installation
│   └── setup-linux.yml     # Linux software installation
├── dot_config/             # Application configs
│   ├── fish/               # Fish shell configuration
│   ├── bat/                # Bat configuration
│   ├── ghostty/            # Ghostty terminal config
│   └── starship.toml       # Starship prompt config
├── run_once_01_install_homebrew.sh.tmpl  # Homebrew setup
└── run_once_02_install_ansible.sh.tmpl   # Ansible setup & execution
```
