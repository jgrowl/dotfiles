if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # TODO: Test this.
    ZSHRC_LINK_FILE="${(%):-%N}"
    ZSHRC_FILE="$(readlink -f "$ZSHRC_LINK_FILE")"
    DOTFILESDIR=$(dirname $ZSHRC_FILE)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ZSHRC_LINK_FILE="${(%):-%N}"
    ZSHRC_FILE="$(greadlink -f "$ZSHRC_LINK_FILE")"
    DOTFILESDIR=$(dirname $ZSHRC_FILE)
elif [[ "$OSTYPE" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
    # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    # ...
else
    # Unknown.
fi

# The cannonical path to the dotfiles directory
export DOTFILESDIR

export DOTFILESLIBDIR=$DOTFILESDIR/lib

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$DOTFILESLIBDIR/oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILESDIR/custom
export ZSH_CUSTOM

export ZSH_CUSTOM_PLUGINS=$ZSH_CUSTOM/plugins

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(jgrowl git vi-mode pass ssh-agent gpg-agent)

# I'm monkey patching this my own custom ssh-add that calls pass to get passwords
alias ssh-add="$DOTFILESDIR/bin/ssh-add-pass"
source $ZSH/oh-my-zsh.sh
unalias ssh-add
