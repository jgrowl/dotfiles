#https://unix.stackexchange.com/questions/136423/making-zsh-default-shell-without-root-access
export SHELL=`which zsh`
[ -z "$ZSH_VERSION" ] && exec "$SHELL" -l
