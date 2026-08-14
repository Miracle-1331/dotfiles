# dotfiles

Reproducible dev-machine bootstrap for macOS and Ubuntu/Debian.

## Quick start

```sh
git clone git@github.com:Miracle-1331/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script is idempotent — safe to re-run at any time.

## What it installs

| Category | Tools |
|---|---|
| Package manager | Homebrew on macOS, Linuxbrew on Ubuntu |
| Shell | zsh + oh-my-zsh + powerlevel10k (with `zsh-autosuggestions` and `zsh-syntax-highlighting`) |
| Version managers | `nvm` (Node), `uv` (Python), `goenv` (Go), `tfenv` (Terraform) |
| Kubernetes | `kubectl`, `helm`, `kind`, `k3d`, `istioctl`, `argocd`, `kubectl-argo-rollouts` |
| Containers | `docker` CLI + Buildx + Compose, `colima` (macOS), Docker Desktop cask (macOS) |
| Cloud | `awscli` |
| IaC & security | `tfenv`, `tflint`, `cosign`, `trivy`, `gitleaks` |
| Editors & shell tooling | `neovim`, `gh`, `jq`, `yq`, `tree`, `htop`, `watch`, `actionlint`, `shfmt` |
| Extras | Claude Code CLI, `it2` (iTerm2 helper) |
| macOS defaults | Keyboard, Finder, Dock, screenshots |

Full package list lives in [`Brewfile`](./Brewfile).

## Layout

```
install.sh                   # entrypoint
Brewfile                     # `brew bundle` package list (with `if OS.mac?` guards)
home/                        # files symlinked into $HOME
  .zshrc                     # interactive shell config
  .p10k.zsh                  # powerlevel10k customization
  .gitconfig
  .zshrc.local.example       # template for machine-local secrets (see below)
scripts/
  macos-defaults.sh          # `defaults write` tweaks (macOS only)
```

## Steps

Run everything, or one step at a time:

```sh
./install.sh                 # full run
./install.sh brew            # just Homebrew + Brewfile
./install.sh omz link        # oh-my-zsh, then symlinks
./install.sh --help          # list of steps
```

| Step | What it does |
|---|---|
| `brew` | Installs Homebrew (Linuxbrew on Ubuntu, prereq apt packages first), then `brew bundle` |
| `omz` | Installs oh-my-zsh, powerlevel10k, and the two custom plugins |
| `link` | Symlinks every file in `home/` into `$HOME`, backing up existing files first |
| `hooks` | Points `core.hooksPath` at `./hooks` so `gitleaks` runs before every commit |
| `versions` | Installs `nvm` and `uv` (goenv/tfenv come from Brewfile) |
| `extras` | Installs Claude Code CLI (`claude`) and `it2` via `uv tool install` |
| `macos` | Applies macOS `defaults` (no-op on Linux) |

## Secrets

The committed `~/.zshrc` sources `~/.zshrc.local` at the end. That file is
gitignored — put tokens and machine-specific overrides there.

```sh
cp home/.zshrc.local.example ~/.zshrc.local
$EDITOR ~/.zshrc.local        # fill in ARGOCD_TOKEN, VAULT_HEADERS, etc.
```

Never commit real secrets to `home/.zshrc` or any other tracked file.

After running `./install.sh hooks` (bundled into a full run), every `git
commit` in this repo is gated by `hooks/pre-commit` — it runs `gitleaks
git --pre-commit --staged` and blocks the commit if any credential-shaped
string appears in the staged diff. Bypass in a genuine emergency with
`git commit --no-verify` (then rotate the secret and try again).

## Existing files are never lost

When `link` finds a file already present at the target path, it's moved to:

```
~/.dotfiles-backup/<timestamp>/
```

before the symlink is created. Roll back by copying files out of the timestamped
backup directory.

## Cross-platform notes

- macOS-only entries (`cask "docker-desktop"`, `brew "colima"`) are wrapped in
  `if OS.mac?` in the Brewfile — Linuxbrew skips them cleanly.
- The `macos` step is a no-op on Linux.
- On Ubuntu, `install.sh` runs `sudo apt-get install -y build-essential procps
  curl file git zsh ca-certificates` before bootstrapping Linuxbrew.
- The `.zshrc` guards macOS-only PATH entries with `[[ -d ... ]]` so Linux
  shells don't accumulate phantom paths.
