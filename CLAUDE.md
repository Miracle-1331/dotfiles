# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A cross-platform (macOS + Ubuntu) dev-machine bootstrap. `install.sh` is the
only entrypoint; everything else is data or scripts it invokes. There is no
build system, no test runner, no CI. See `README.md` for the user-facing
quick start.

## Common commands

```sh
./install.sh                 # full run (idempotent)
./install.sh <step> [...]    # run named step(s); see --help
bash -n install.sh           # syntax-check the script (do this before every commit)
bash -n scripts/macos-defaults.sh
ruby -c Brewfile             # Brewfile is Ruby — parse-check after edits

brew bundle check --verbose --file=Brewfile   # compare Brewfile to installed formulae
brew bundle --file=Brewfile                   # install anything missing
```

`brew bundle check` will always report `awscli` as "missing" on the
source machine — it was installed via Amazon's pkg installer, not via
Homebrew. On a fresh machine, `brew bundle` will install it properly.
Do not "fix" the diff by removing that line.

## Architecture

`install.sh` is a step-based orchestrator. Steps are `brew | omz | link |
versions | extras | macos`; each is a `step_<name>()` bash function, and
they're invoked in that order by default. Every step must be **idempotent**
(check-then-do), because users re-run this on existing machines to pick up
new packages.

Three cross-cutting mechanisms are the load-bearing parts:

1. **OS detection** — `detect_os` sets `$OS` to `macos` or `linux` (apt
   required on Linux; anything else errors out). `brew_shellenv` probes
   `/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew`, `~/.linuxbrew`
   in order and sources whichever exists. Any new step that needs `brew` on
   PATH should call `brew_shellenv` rather than hardcoding a path.

2. **Backup-then-symlink** — `link <src> <dst>` in `install.sh` is the only
   correct way to install a dotfile. It no-ops if the symlink is already
   correct, moves anything else to `$BACKUP_DIR` (`~/.dotfiles-backup/<ts>/`)
   before creating the symlink, and never deletes user data. `step_link`
   walks `home/*` and calls `link` for each entry.

3. **`if OS.mac?` guards** — the Brewfile is Ruby. Casks aren't supported by
   Linuxbrew, and `colima` is macOS-only, so both live inside an
   `if OS.mac? ... end` block. Add any future macOS-only formulae there.

## Adding things

- **New Homebrew package**: add to `Brewfile` under the matching section,
  then `brew bundle --file=Brewfile`. The Brewfile is the source of truth
  — do NOT `brew install` outside of it or the next `install.sh` run
  will diverge from reality.

- **New dotfile**: drop the file at `home/<name>` (e.g. `home/.tmux.conf`).
  `step_link` picks it up automatically. Files ending in `*.local.example`
  are treated as templates and intentionally NOT symlinked — use that
  suffix for anything containing secrets that should be copied and edited,
  not linked.

- **New install step**: (1) write `step_<name>()`, (2) add `<name>` to the
  case-glob in `main` AND to the default `steps=(...)` array, (3) add a line
  to `usage()`. All three or the step is unreachable.

- **New macOS default**: add a `defaults write` line to
  `scripts/macos-defaults.sh` and, if the affected app needs a restart,
  add it to the `killall` loop at the bottom.

## Secrets

`home/.zshrc` deliberately ends with `[[ -f ~/.zshrc.local ]] && source
~/.zshrc.local`. `~/.zshrc.local` is gitignored via `.gitignore` at the repo
root; `home/.zshrc.local.example` is the committed template. **All tokens,
CF Access secrets, VAULT_HEADERS, ARGOCD_TOKEN, etc. belong in
`~/.zshrc.local` — never in any tracked file.**

A pre-commit hook at `hooks/pre-commit` runs `gitleaks git --pre-commit
--staged` on every commit (activated by `install.sh hooks`, which points
`core.hooksPath` at `./hooks`). It's the enforcement layer for the rule
above. `.github/workflows/trivy.yml` re-scans full history in CI as a
belt-and-suspenders backstop.

## Repo-specific quirks

- `.claude/settings.local.json` is machine-local and excluded by the user's
  **global** git ignore (`~/.config/git/ignore` → `**/.claude/settings.local.json`),
  not by this repo's `.gitignore`. It won't show up in `git status`; don't
  try to add it.
- Container runtime on macOS is **colima**, not Docker Desktop. The
  Brewfile installs `brew "docker"` (CLI) + `brew "colima"` (daemon).
  If a fresh Mac still has `Docker.app` from a prior install, uninstall
  it before running `install.sh` — otherwise its `docker` at
  `/usr/local/bin/docker` will shadow the brew CLI, and its completion
  symlinks will conflict with the `docker` formula's link step.
- `tflint` is shipped by `terraform-linters/tap` as a **cask**, not a
  formula. It lives inside the `if OS.mac?` block alongside colima.
  Linux users who want it must install manually.
