# dotfiles

This repo contains the configuration to setup my machines. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install.

Automated package installation currently targets macOS with Homebrew. Linux
package management is deferred; the existing Linux Homebrew bootstrap remains.

## How to run

```shell
# SSH Authentication
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --ssh

# Or with Github Token
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

## Development checks

This repository uses a pre-commit-compatible configuration with `prek`.
Homebrew packages include `prek` and `shellcheck`; the shell hook also uses
chezmoi and Fish.

```shell
prek install
prek run --all-files
```

Hooks check config syntax (JSON, TOML, and YAML), merge conflicts, filename case
conflicts, large files, private keys, final newlines, and trailing whitespace.
ShellCheck checks shell scripts, and Fish checks its own syntax. Chezmoi shell
templates are rendered for both macOS and Linux before checking; hooks never
execute setup scripts or install packages. Whitespace hooks can fix files;
review and stage those fixes before retrying the commit.

## What gets installed

### Initial Setup
1. **Homebrew** - Bootstrapped before package installation
2. **Homebrew Bundle** - Installs the declared macOS formulae and casks

### Managing macOS packages

Edit `.chezmoidata/packages.yaml`: put formulae under `packages.darwin.brews`
and casks under `packages.darwin.casks`, then run `chezmoi apply`. This follows
the [chezmoi declarative package pattern](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/).

The package script runs on its first apply and whenever its rendered contents
change. Unchanged applies skip it, and failed runs are retried on the next apply.
It uses `brew bundle --no-upgrade` to install missing packages without explicitly
upgrading existing ones. Homebrew may still upgrade dependencies required for an
installation. Removing an entry does not uninstall the package.

To reinstall manually removed packages without changing the declaration, rerun
only the package script:

```shell
(
  set -e
  package_script="$(mktemp)"
  trap 'rm -f "$package_script"' EXIT
  chezmoi execute-template --file "$(chezmoi source-path)/.chezmoiscripts/run_onchange_02_install_packages.sh.tmpl" > "$package_script"
  bash "$package_script"
)
```

### Software Stack
- **Shell**: Fish shell with Starship prompt
- **Terminal**: Ghostty (Mac), system terminal (Linux)
- **Editor**: Neovim with VS Code
- **Development Tools**: Git Delta, UV (Python), Just, JQ
- **System Tools**: Bat, Eza, Fd, Ripgrep, Zoxide, Dust, Duf
- **Media Tools**: FFmpeg, Gallery-dl, Yt-dlp
- **Networking**: Curlie, HTTPie, Doggo, Gping
- **Fonts**: Nerd Font variants (Mac only)

### Configuration Files
- **Git**: Delta diff viewer, improved merge conflicts
- **Tmux**: Catppuccin theme, custom key bindings
- **Fish**: Completions for CLI tools, custom functions
- **Starship**: Cross-shell prompt configuration
- **Bat**: Catppuccin themes downloaded to `~/.config/bat/themes` by chezmoi
  externals, with Mocha selected. After apply, the cache is rebuilt only when
  theme files or the bat version change, or cache files are missing.
  This maintenance script is omitted from `chezmoi diff` and `chezmoi status`.
- **Eza**: Catppuccin Mocha with a mauve accent downloaded to
  `~/.config/eza/theme.yml`; the Fish wrapper lets the native theme take
  precedence over vivid's `LS_COLORS` for eza.

External downloads are grouped by category in `.chezmoiexternals/*.toml`:
`themes.toml` contains Catppuccin themes, and `plugins.toml` contains TPM and
bash-preexec.
Setup and maintenance scripts live in `.chezmoiscripts/`; their numbered names
keep Homebrew setup before package installation, and the bat cache rebuild runs
after files and externals are applied.

## Directory Structure

```
├── .chezmoidata/
│   └── packages.yaml       # Declarative macOS formulae and casks
├── .chezmoiexternals/      # External downloads by category
│   ├── plugins.toml        # TPM and bash-preexec
│   └── themes.toml         # Catppuccin themes for Atuin, bat, eza, and Micro
├── .chezmoiscripts/        # Setup and maintenance scripts
│   ├── run_once_01_install_homebrew.sh.tmpl
│   ├── run_onchange_02_install_packages.sh.tmpl
│   └── run_after_03_rebuild_bat_cache.sh
└── dot_config/             # Application configs
    ├── fish/               # Fish shell configuration
    ├── bat/                # Bat configuration
    ├── ghostty/            # Ghostty terminal config
    └── starship.toml       # Starship prompt config
```
