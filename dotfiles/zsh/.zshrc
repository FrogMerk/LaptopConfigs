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

# --- tools ------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --info=inline --color=bg+:#343F44,bg:#2D353B,spinner:#A7C080,hl:#A7C080,fg:#D3C6AA,header:#7FBBB3,info:#DBBC7F,pointer:#A7C080,marker:#D699B6,fg+:#D3C6AA,prompt:#A7C080,hl+:#A7C080"
  source <(fzf --zsh)
fi

# Syntax highlighting must be sourced last.
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# --- environment ------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PAGER=less
export LESS='-R'

if command -v micro >/dev/null 2>&1; then
  export EDITOR=micro
  export VISUAL=micro
elif command -v nano >/dev/null 2>&1; then
  export EDITOR=nano
  export VISUAL=nano
fi

# --- aliases ----------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first'
  alias la='eza -A --icons --group-directories-first'
  alias l='eza -CF --icons --group-directories-first'
  alias tree='eza --tree --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah'
  alias la='ls -A'
  alias l='ls -CF'
fi
alias grep='grep --color=auto'
alias lg='lazygit'
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
