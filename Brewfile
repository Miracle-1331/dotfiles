# Managed by install.sh — `brew bundle --file=Brewfile`.
# Snapshot of `brew leaves` on the source machine.

tap "hashicorp/tap"
tap "terraform-linters/tap"

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
brew "k3d"
brew "argocd"
brew "podman"            # container engine (uses a VM on macOS)
brew "podman-compose"    # Compose provider for `podman compose`

# --- Cloud CLIs ---------------------------------------------------------------
brew "awscli"            # AWS CLI v2
brew "azure-cli"         # Azure CLI (`az`)

# --- macOS-only ---------------------------------------------------------------
# Casks aren't supported on Linuxbrew.
if OS.mac?
  cask "freelens"              # Kubernetes IDE
  cask "iterm2"                # terminal application
  cask "tflint"                 # terraform-linters ships tflint as a cask, not a formula
  cask "font-jetbrains-mono"    # terminal / editor font
end

# --- Terraform / IaC ----------------------------------------------------------
brew "tfenv"             # terraform version manager

# --- Networking ---------------------------------------------------------------
brew "nmap"              # port scanner / host discovery
brew "tcpdump"           # packet capture (may need sudo)
brew "mtr"               # traceroute + ping combined
brew "iperf3"            # network throughput benchmarking
brew "bind"              # dig, host, nslookup (keg-only — add $(brew --prefix bind)/bin to PATH)

# --- Supply-chain / security --------------------------------------------------
brew "trivy"

# --- Languages / runtimes -----------------------------------------------------
brew "goenv"             # Go version manager

# --- Other tools --------------------------------------------------------------
brew "rtk"               # Rust Token Killer proxy (personal tool)
