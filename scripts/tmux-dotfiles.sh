#!/bin/bash

SESH="dotfiles"
EDITOR="nvim"
DOTFILES="~/.local/share/chezmoi"

tmux has-session -t $SESH 2>/dev/null

if [ $? != 0 ]; then 
	tmux new-session -d -s $SESH -n "editor"
	tmux send-keys -t $SESH:editor "cd $DOTFILES" C-m
	tmux send-keys -t $SESH:editor "$EDITOR ." C-m

	tmux new-window -t $SESH -n "shell"
	tmux send-keys -t $SESH:shell "cd $DOTFILES" C-m
	tmux send-keys -t $SESH:shell "ls -l" C-m

	tmux select-window -t $SESH:editor
fi

tmux attach-session -t $SESH
