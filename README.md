# dotfiles

This repo contains the configuration to setup my machines. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install.

This automated setup is currently only configured for Mac OS.

## How to run

```shell
# SSH Authentication
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --ssh

# Or with Github Token
export GITHUB_USERNAME=LoLsAlEd
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
