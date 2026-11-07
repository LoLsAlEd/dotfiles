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
1. **1Password CLI** - On macOS, bootstrapped before source templates are read;
   installs Homebrew first if needed
2. **Homebrew** - Bootstrapped before package installation on other setup paths
3. **Homebrew Bundle** - Installs the declared macOS formulae and casks
4. **Fish plugins** - Synchronizes the declared Fisher plugins after applying files

Homebrew is initialized before Fish loads prompts and completions. macOS shell
paths support both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`).
GitHub CLI is installed for Git credential handling; authenticate your account
with `gh auth login` before using authenticated GitHub HTTPS operations.

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
- **Shell History**: Atuin (initialized automatically in interactive Fish)
- **Terminal**: Ghostty (Mac), system terminal (Linux)
- **Editor**: Neovim with VS Code
- **Development Tools**: Git Delta, UV (Python), Just, JQ
- **System Tools**: Bat, Eza, Fd, Ripgrep, Zoxide, Dust, Duf
- **Media Tools**: FFmpeg, Gallery-dl, Yt-dlp
- **Networking**: Curlie, HTTPie, Doggo, Gping
- **Fonts**: Nerd Font variants (Mac only)
- **Mac Apps**: Rectangle for window management, QLMarkdown for Markdown Quick Look
  previews, and 1Password CLI for integration with a separately installed
  1Password desktop app

### 1Password setup and optional Git signing

On macOS, a `hooks.read-source-state.pre` hook runs
`.install-password-manager.sh` before chezmoi reads source templates. It exits
immediately if `op` is on PATH or in either standard Homebrew location. Otherwise
it installs the CLI through Homebrew, reusing the existing Homebrew bootstrap if
Homebrew is missing. The CLI remains in the package list for normal management.
Chezmoi is configured with an absolute CLI path, so secret lookups also work
before the current shell has loaded Homebrew's environment.

The hook also runs for source-reading commands such as `diff` and during dry runs;
on a Mac without `op`, those commands can trigger installation. It never signs in
or reads vault secrets. Linux setup is unchanged. Existing machines pick up the
hook configuration by running `chezmoi init` again.

Install the 1Password desktop app separately if needed; its existing installation
and updates are left to 1Password. Sign in to the desktop app, open Settings >
Developer, enable the SSH agent, and enable "Integrate with 1Password CLI". The
managed SSH configuration already uses the 1Password agent socket;
host-specific identities are preserved.
See the [SSH agent setup](https://www.1password.dev/ssh/get-started) and
[CLI integration guide](https://www.1password.dev/cli/app-integration).

Interactive macOS initialization offers an optional Git signing public-key
prompt. Paste the full public key from your SSH key item in 1Password, or leave
it empty to disable signing. The value is stored as `gitSigningKey` under
`[data]` in your local chezmoi configuration, not in this repository.

On an existing machine, add or change `gitSigningKey` under `[data]` in
`~/.config/chezmoi/chezmoi.toml`, then run `chezmoi apply`. Set it to an empty
string to disable the managed signing configuration. Missing or empty values
leave signing disabled, and Linux does not receive the 1Password signing settings.
Non-interactive initialization preserves a supplied value or defaults to empty
without asking for a signing key.

When a key is configured on macOS, Git signs commits automatically using
1Password's `op-ssh-sign`. Rendering the configuration does not access your
vault or require the app to be installed yet. Register the public key as a
signing key with your Git hosting provider to have signatures verified there.
See [1Password Git signing](https://www.1password.dev/ssh/git-commit-signing).

For local SSH signature verification, chezmoi also generates
`~/.config/git/allowed_signers` from your configured email and signing public key,
and sets `gpg.ssh.allowedSignersFile` to that path. This is enabled alongside
signing on macOS; missing or empty keys and Linux do not manage the file.
After applying, verify an existing signed commit with `git verify-commit HEAD`
or display it with `git log --show-signature -1`. An SSH signature needs this
local trust file even if GitHub already shows the commit as Verified. Existing
GitHub-created GPG signatures continue to use your GPG keyring for verification.

Future secret-backed dotfiles can use the built-in template function:

```text
{{ onepasswordRead "op://vault/item/field" }}
```

Authenticate with the desktop integration or an `op` session before rendering
secret-backed files. Keep secret references in the repository and retrieve values
in the target file templates, rather than persisting secrets in chezmoi's local
`[data]`. The initial `.chezmoi.toml.tmpl` runs before the bootstrap hook and must
not depend on vault lookups. See the
[chezmoi bootstrap pattern](https://www.chezmoi.io/user-guide/advanced/install-your-password-manager-on-init/)
and [1Password integration](https://www.chezmoi.io/user-guide/password-managers/1password/).

### Markdown Quick Look previews

After installation, launch QLMarkdown once so macOS discovers its Quick Look
extension. Select a Markdown file in Finder and press Space to check the preview.
If it does not render, check System Settings > General > Login Items & Extensions
> Quick Look and enable QLMarkdown. See the
[QLMarkdown setup instructions](https://github.com/sbarex/QLMarkdown#installation).

### Configuration Files
- **Git**: Delta diff viewer, improved merge conflicts, optional 1Password commit
  signing on macOS, and a global ignore file at `~/.config/git/ignore` for Mac
  metadata and editor temporary files. Project files, `.env` files, and lockfiles
  are not globally ignored; the existing local Claude Code settings exclusion
  (`**/.claude/settings.local.json`) is preserved.
- **Tmux**: Catppuccin theme, custom key bindings
- **Fish**: Completions for CLI tools, custom functions, and Fisher plugins from
  `dot_config/fish/fish_plugins`; changes to the list are synchronized on apply
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
keep Homebrew setup before package installation. The bat cache rebuild and Fish
plugin synchronization run after files and externals are applied. Fish plugin
installation currently targets macOS; Linux package management remains deferred.

## Directory Structure

```
├── .chezmoidata/
│   └── packages.yaml       # Declarative macOS formulae and casks
├── .chezmoiexternals/      # External downloads by category
│   ├── plugins.toml        # TPM and bash-preexec
│   └── themes.toml         # Catppuccin themes for Atuin, bat, eza, and Micro
├── .chezmoiscripts/        # Setup and maintenance scripts
│   ├── run_once_01_install_homebrew.sh
│   ├── run_onchange_02_install_packages.sh.tmpl
│   ├── run_after_03_rebuild_bat_cache.sh
│   └── run_onchange_after_04_install_fish_plugins.sh.tmpl
└── dot_config/             # Application configs
    ├── fish/               # Fish shell configuration
    ├── bat/                # Bat configuration
    ├── ghostty/            # Ghostty terminal config
    └── starship.toml       # Starship prompt config
```
