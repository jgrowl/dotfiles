#!/bin/bash

# update with zsh, but current script 'cannot find pane'
#!/usr/bin/zsh

BASENAME=`basename $PWD`
echo "Using session name '$BASENAME'"
SESH=$BASENAME

tmux has-session -t $SESH 2>/dev/null
if [ $? != 0 ]; then 
	WORKINGDIR=$PWD
	echo "Setting session working directory as '$WORKINGDIR'"

	tmux new-session -d -s $SESH -n "editor"
	tmux send-keys -t $SESH:editor "cd $WORKINGDIR" C-m
	tmux send-keys -t $SESH:editor "$EDITOR ." C-m

	tmux new-window -t $SESH -n "shell"
	tmux send-keys -t $SESH:shell "cd $WORKINGDIR" C-m
	tmux send-keys -t $SESH:shell "ls -l" C-m

	tmux select-window -t $SESH:editor
fi

tmux attach-session -t $SESH
