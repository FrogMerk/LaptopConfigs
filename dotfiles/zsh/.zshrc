# ~/.zshrc
# Everforest Dark (medium) shell setup.

# --- history ---------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# --- navigation and input ---------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
unsetopt BEEP
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# --- completions ------------------------------------------------------------
# zsh-completions installs into /usr/share/zsh/site-functions, already on fpath.
autoload -Uz compinit && compinit -i
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#DBBC7F}-- %d --%f'
setopt COMPLETE_IN_WORD

# --- prompt -----------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- plugins ----------------------------------------------------------------
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting must be sourced last.
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# --- environment ------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PAGER=less
export LESS='-R'

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
  alias vim='nvim'
fi

# --- aliases ----------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias pac='sudo pacman'
alias update='sudo pacman -Syu'
alias check='checkupdates'
alias dots='cd ~/LaptopConfigs'
alias maint='~/LaptopConfigs/scripts/maintenance-check.sh'
alias restore-test='~/LaptopConfigs/scripts/test-restore.sh'
alias ports='ss -tulpn'

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}
