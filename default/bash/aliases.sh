# henzOS default shell aliases

# Modern replacements
if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -la --icons'
  alias lt='eza -laT --icons --level=2'
else
  alias ls='ls --color=auto'
  alias ll='ls -la'
fi

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

if command -v fd &>/dev/null; then
  : # fd is already short
elif command -v fdfind &>/dev/null; then
  alias fd='fdfind'
fi

# Git shortcuts
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias lg='lazygit'

# Docker
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# System
alias reload='source ~/.bashrc'
alias ..='cd ..'
alias ...='cd ../..'
