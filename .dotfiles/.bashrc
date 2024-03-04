. /usr/share/bash-completion/completions/git

. ~/.dotfiles/.commonrc

export PATH="/home/tj/.local/bin/poetry:$PATH"
export PATH="/home/tj/.cache/pypoetry/virtualenvs/fka-databricks-GAMMsPWM-py3.10/bin/python:$PATH"
export PYTHONPATH="/home/tj/.cache/pypoetry/virtualenvs/fka-databricks-GAMMsPWM-py3.10/lib/python3.10/site-packages:$PYTHONPATH"


export HISTSIZE=1000
export HISTFILESIZE=2000

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

eval "$(starship init bash)"
eval "$(mcfly init bash)"
eval "$(zoxide init bash)"
