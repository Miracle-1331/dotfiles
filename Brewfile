# Managed by install.sh — `brew bundle --file=Brewfile`.
# Snapshot of `brew leaves` on the source machine.

tap "argoproj/tap"
tap "hashicorp/tap"

# --- Linters, formatters, dev-loop --------------------------------------------
brew "actionlint"        # GitHub Actions workflow linter
brew "gitleaks"          # secret scanner
brew "shfmt"             # shell formatter
brew "neovim"

# --- General CLI --------------------------------------------------------------
brew "gh"                # GitHub CLI
brew "htop"
brew "jq"
brew "yq"
brew "tree"
brew "watch"

# --- Kubernetes / container ecosystem -----------------------------------------
brew "kubernetes-cli"    # kubectl (bundles `kubectl kustomize`)
brew "helm"
brew "kind"
brew "k3d"
brew "istioctl"
brew "argocd"
brew "argoproj/tap/kubectl-argo-rollouts"
brew "docker"            # CLI (Docker Desktop ships its own CLI too — this is a fallback)
brew "docker-buildx"
brew "docker-compose"

# --- Cloud CLIs ---------------------------------------------------------------
brew "awscli"            # AWS CLI v2

# --- macOS-only ---------------------------------------------------------------
# Casks aren't supported on Linuxbrew; colima is macOS-only in practice.
if OS.mac?
  brew "colima"          # rootless container runtime alternative to Docker Desktop
  cask "docker-desktop"  # Docker Desktop.app — accept the license on first launch
end

# --- Terraform / IaC ----------------------------------------------------------
brew "tfenv"             # terraform version manager
brew "tflint"

# --- Supply-chain / security --------------------------------------------------
brew "cosign"
brew "trivy"

# --- Languages / runtimes -----------------------------------------------------
brew "goenv"             # Go version manager

# --- Other tools --------------------------------------------------------------
brew "rtk"               # Rust Token Killer proxy (personal tool)
