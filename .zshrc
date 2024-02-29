# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:$PATH"
# Poetry path
export PATH="/home/tj/.local/bin/poetry:$PATH"
export PATH="/home/tj/.cache/pypoetry/virtualenvs/fka-databricks-GAMMsPWM-py3.10/bin/python:$PATH"
export PYTHONPATH="/home/tj/.cache/pypoetry/virtualenvs/fka-databricks-GAMMsPWM-py3.10/lib/python3.10/site-packages:$PYTHONPATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

HIST_STAMPS="yyyy-mm-dd"

# Standard plugins can be found in $ZSH/plugins/
plugins=(git gh fzf pip python poetry poetry-env)

source $ZSH/oh-my-zsh.sh

# Example aliases
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"
alias dev="cd ../../mnt/c/dev"

# Created by `pipx` on 2024-02-28 16:22:39
export PATH="$PATH:/home/tj/.local/bin"

