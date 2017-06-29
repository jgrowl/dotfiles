# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#
#

export ZSH_CUSTOM_JGROWL_PLUGIN=$ZSH_CUSTOM_PLUGINS/jgrowl

export CODEDIR=$HOME/Code
c() { cd $CODEDIR/$1; }
_c() { _files -W $CODEDIR -/; }
compdef _c c

h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h

.d() { cd $DOTFILESDIR/$1; }
_.d() { _files -W $DOTFILESDIR -/; }
compdef _.d .d

export ACTIVEDIR=$CODEDIR/active

a() { cd $ACTIVEDIR/$1; }
_a() { _files -W $ACTIVEDIR -/; }
compdef _a a

export ZSH_CUSTOM_JGROWL_PLUGIN_BIN=$ZSH_CUSTOM_JGROWL_PLUGIN/bin
export ZSH_CUSTOM_JGROWL_PLUGIN_SCRIPTS=$ZSH_CUSTOM_JGROWL_PLUGIN/scripts

s() { $ZSH_CUSTOM_JGROWL_PLUGIN_SCRIPTS/$1; }
_s() { _files -W $ZSH_CUSTOM_JGROWL_PLUGIN_SCRIPTS -/; }
compdef _s s

# autocorrect is more annoying than helpful
#unsetopt correct_all

# Rebind incremental search because of vi mode
bindkey -M vicmd '?' history-incremental-search-backward

#export SPACEVIMDIR=$DOTFILESDIR/SpaceVim.d

# Add plugin's bin directory to path
export PATH="$(dirname $0)/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

# Platform specific variables
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # TODO: add path
elif [[ "$OSTYPE" == "darwin"* ]]; then
    RUST_SRC_PATH=~/.multirust/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src
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

export RUST_SRC_PATH
