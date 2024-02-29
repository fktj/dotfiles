. /usr/share/bash-completion/completions/git

. ~/.dotfiles/.commonrc

export HISTSIZE=1000
export HISTFILESIZE=2000

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

eval "$(starship init bash)"
eval "$(mcfly init bash)"
eval "$(zoxide init bash)"