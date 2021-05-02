# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=3000
setopt appendhistory extendedglob
unsetopt autocd
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

# uncomment and update
# zstyle :compinstall filename '/home/user/.zshrc'

autoload -Uz compinit
compinit

# Customs

# Git branch name in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
# formatting for VCS
zstyle ':vcs_info:git:*' formats '(%b) '

setopt PROMPT_SUBST
export PROMPT='%{%F{222}%}%n%{%f%}: %c %F{245}${vcs_info_msg_0_}%f$ '

# exit code on RHS
export RPROMPT='%F{240}$?%f'

# aliases
alias ls='ls -GF --color=auto'
alias ll='ls -l'
alias la='ls -a'

# pipenv config
alias pipenv='python3.9 -m pipenv'
export PIPENV_VENV_IN_PROJECT=1
