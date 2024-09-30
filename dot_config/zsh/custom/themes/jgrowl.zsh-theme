# Put your custom themes in this folder.
# See: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-themes
#
# Example:
#PROMPT="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%- %{$reset_color%}%% "

PROMPT=""
#PROMPT="%{$fg_bold[cyan]%}%n"
#PROMPT+="%{$fg[white]%}@"
#PROMPT+="%{$fg[blue]%}%m"
PROMPT+="%{$fg[cyan]%}%c%{$reset_color%} "
PROMPT+='$(git_prompt_info)'
PROMPT+='%(?:%{$fg_bold[green]%}%1{☺%} :%{$fg_bold[red]%}%1{☹%} )%{$reset_color%}'
#PROMPT+='${NEWLINE} ➤%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

NEWLINE=$'\n'
#➤
