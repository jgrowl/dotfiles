#export GITHUBCODEDIR=$CODEDIR/github.com
#export JGROWLCODEDIR=$GITHUBCODEDIR/jgrowl
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

alias active-toggle='unlink $ACTIVEDIR &> /dev/null; ln -s $PWD $ACTIVEDIR'

# autocorrect is more annoying than helpful
#unsetopt correct_all

# Rebind incremental search because of vi mode
bindkey -M vicmd '?' history-incremental-search-backward

export SSH_ADD_ORIGINAL=$(whereis ssh-add)

# Add plugin's bin directory to path
export PATH="$(dirname $0)/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"
