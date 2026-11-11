# Zsh Configuration

# History
#HISTFILE=~/.cache/zsh/history
#HISTSIZE=10000
#SAVEHIST=10000
#setopt INC_APPEND_HISTORY
#setopt EXTENDED_HISTORY
#setopt HIST_IGNORE_DUPS

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completion
autoload -Uz compinit
compinit
setopt MENU_COMPLETE
setopt COMPLETE_IN_WORD

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -la'
alias cd..='cd ..'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias vim='nvim'
alias vi='nvim'
alias cat='bat --style=plain' # if bat is installed
alias ps='ps aux'

# Prompt (use starship if installed)
eval "$(starship init zsh)"

# FZF integration (if fzf is installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add local bin to PATH
export PATH="$PATH:$HOME/.local/bin"
