#!/usr/bin/env bash
# Dotfile bootstrap for macOS and Ubuntu/Debian.
#
# Reproduces this machine's setup on a fresh box:
#   - Homebrew (Linuxbrew on Linux) + Brewfile packages
#   - oh-my-zsh with powerlevel10k and custom plugins
#   - nvm (Node), uv (Python)  — goenv & tfenv come from Brewfile
#   - ~/.zshrc, ~/.p10k.zsh, ~/.gitconfig symlinks
#   - Sensible macOS `defaults` (macOS only)
#
# Idempotent: safe to re-run. Existing conflicts are moved to
# ~/.dotfiles-backup/<timestamp>/ before we replace them with symlinks.
#
# Usage:
#   ./install.sh                # everything
#   ./install.sh brew link      # only these steps
#   ./install.sh --help

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

BOLD=$'\033[1m'; RESET=$'\033[0m'
GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; BLUE=$'\033[34m'

log()  { printf '%s==>%s %s%s%s\n' "$BLUE" "$RESET" "$BOLD" "$*" "$RESET"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '  %sx%s %s\n' "$RED" "$RESET" "$*" >&2; }

OS=""     # "macos" | "linux"

detect_os() {
  case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)
      if ! command -v apt-get >/dev/null 2>&1; then
        err "Linux support requires apt-get (Debian/Ubuntu). Detected: $(uname -a)"
        exit 1
      fi
      OS=linux
      ;;
    *) err "Unsupported OS: $(uname -s)"; exit 1 ;;
  esac
  ok "detected OS: $OS"
}

brew_shellenv() {
  local p
  for p in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"
  do
    if [[ -x "$p" ]]; then
      eval "$("$p" shellenv)"
      return 0
    fi
  done
  return 1
}

ensure_backup_dir() { [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"; }

# link <src> <dst>
#   noop if dst already points to src; otherwise backs up dst and symlinks.
link() {
  local src="$1" dst="$2"
  if [[ ! -e "$src" ]]; then
    warn "source missing, skipping: $src"
    return
  fi
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "already linked: $dst"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    ensure_backup_dir
    mv "$dst" "$BACKUP_DIR/"
    warn "backed up $dst -> $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "linked $dst -> $src"
}

step_brew() {
  if [[ "$OS" == linux ]]; then
    log "apt prerequisites for Linuxbrew and shell tools"
    sudo apt-get update
    sudo apt-get install -y \
      build-essential procps curl file git zsh ca-certificates
  fi

  log "Homebrew"
  if command -v brew >/dev/null 2>&1 || brew_shellenv; then
    ok "Homebrew already installed"
  else
    warn "Installing Homebrew (may prompt for sudo)"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_shellenv || { err "brew not on PATH after install"; return 1; }
  fi

  log "brew bundle"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
}

step_omz() {
  log "oh-my-zsh + powerlevel10k + custom plugins"

  # oh-my-zsh core
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "oh-my-zsh already installed"
  else
    warn "Installing oh-my-zsh"
    # KEEP_ZSHRC=yes prevents the installer from clobbering the .zshrc we'll link later.
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes /bin/sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

  # powerlevel10k theme
  if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    ok "powerlevel10k already installed"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$ZSH_CUSTOM/themes/powerlevel10k"
  fi

  # zsh-autosuggestions
  if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    ok "zsh-autosuggestions already installed"
  else
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # zsh-syntax-highlighting
  if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    ok "zsh-syntax-highlighting already installed"
  else
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi
}

step_link() {
  log "Symlink dotfiles into \$HOME"
  # Every top-level file under home/ is linked to \$HOME/<same-name>,
  # except *.local.example which is a template — never symlinked.
  local src
  while IFS= read -r -d '' src; do
    local base; base="$(basename "$src")"
    if [[ "$base" == *.local.example ]]; then
      warn "template only, NOT linking: $base (copy to ~/${base%.example} and fill in)"
      continue
    fi
    link "$src" "$HOME/$base"
  done < <(find "$DOTFILES_DIR/home" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)
}

step_versions() {
  log "Language version managers (nvm, uv)"
  # goenv and tfenv come via Homebrew (see Brewfile).

  if [[ -d "$HOME/.nvm" ]]; then
    ok "nvm already installed"
  else
    warn "Installing nvm"
    PROFILE=/dev/null bash -c \
      'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
  fi

  if command -v uv >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/uv" ]]; then
    ok "uv already installed"
  else
    warn "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
}

step_extras() {
  log "Extra CLIs (claude, it2)"

  # Claude Code — Anthropic's native installer places the binary in ~/.local/bin.
  if command -v claude >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/claude" ]]; then
    ok "claude already installed ($("$HOME/.local/bin/claude" --version 2>/dev/null || echo present))"
  else
    warn "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # it2 — iTerm2 helper CLI installed as a uv tool. Requires uv on PATH.
  local UV_BIN
  UV_BIN="$(command -v uv || echo "$HOME/.local/bin/uv")"
  if [[ ! -x "$UV_BIN" ]]; then
    err "uv not found — run \`$(basename "$0") versions\` first"
    return 1
  fi
  if "$UV_BIN" tool list 2>/dev/null | grep -q '^it2 '; then
    ok "it2 already installed"
  else
    warn "Installing it2 via uv"
    "$UV_BIN" tool install it2
  fi
}

step_macos() {
  if [[ "$OS" != macos ]]; then
    warn "skipping macOS defaults on $OS"
    return
  fi
  log "macOS defaults"
  bash "$DOTFILES_DIR/scripts/macos-defaults.sh"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [step ...]

Supports macOS and Ubuntu/Debian. Runs every step in order when called with
no arguments. Available steps:
  brew      Install Homebrew (Linuxbrew on Linux) + Brewfile packages
  omz       Install oh-my-zsh, powerlevel10k, and custom plugins
  link      Symlink files from home/ into \$HOME (with backup)
  versions  Install nvm and uv (goenv/tfenv come from Brewfile)
  extras    Install claude (Claude Code CLI) and it2 (via uv tool)
  macos     Apply macOS system defaults (no-op on Linux)

Existing files that would be overwritten are moved to:
  ~/.dotfiles-backup/<timestamp>/

Secrets:
  Copy home/.zshrc.local.example to ~/.zshrc.local and fill it in —
  ~/.zshrc.local is gitignored and sourced at the end of ~/.zshrc.
EOF
}

main() {
  # Handle --help before anything else so it doesn't print OS detection noise.
  for arg in "$@"; do
    case "$arg" in -h|--help) usage; exit 0 ;; esac
  done

  detect_os

  local steps=()
  if [[ $# -eq 0 ]]; then
    steps=(brew omz link versions extras macos)
  else
    for arg in "$@"; do
      case "$arg" in
        brew|omz|link|versions|extras|macos) steps+=("$arg") ;;
        *) err "unknown step: $arg"; usage; exit 1 ;;
      esac
    done
  fi

  for s in "${steps[@]}"; do "step_${s}"; done

  log "Done."
  [[ -d "$BACKUP_DIR" ]] && warn "Backups saved to $BACKUP_DIR"
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    warn "No ~/.zshrc.local yet — copy home/.zshrc.local.example there for secrets."
  fi
  echo "Open a new terminal (or run: exec zsh) to pick up shell changes."
}

main "$@"
