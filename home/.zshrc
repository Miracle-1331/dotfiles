# ~/.zshrc — managed by dotfile repo.
# Interactive zsh config built on oh-my-zsh + powerlevel10k.

# --- Powerlevel10k instant prompt ---------------------------------------------
# Must stay near the top; anything that may prompt for input must be ABOVE this.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh ----------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan,underline"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
source "$ZSH/oh-my-zsh.sh"

# --- Powerlevel10k config -----------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Homebrew shellenv (Linuxbrew only; macOS uses /etc/paths.d) --------------
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

# --- Aliases ------------------------------------------------------------------
alias cls=clear
alias tf=terraform
alias vi=nvim
alias d=docker
alias k=kubectl
alias ga="git add"
alias gc="git commit -m"
alias gs="git status"
alias gp="git push"
alias ka="kubectl apply -f"
alias kc="kubectl create"
alias kd="kubectl delete"
alias kds="kubectl describe"
alias ke="kubectl edit"
alias kg="kubeclt get"
alias krp="kubectl replace"
alias krpf="kubectl replace --force -f"
alias ksetns="kubectl config set-context --current --namespace"
alias ls="ls -la --color"

# --- Version managers ---------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
command -v goenv >/dev/null 2>&1 && eval "$(goenv init -)"

# --- PATH additions -----------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# --- Functions ----------------------------------------------------------------
ss() {
	sudo lsof -iTCP -iUDP -n -P -sTCP:LISTEN
}

# --- Completions --------------------------------------------------------------
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)

autoload -U +X bashcompinit && bashcompinit
