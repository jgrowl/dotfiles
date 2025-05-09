# dotfiles 

## install

`apt install git`

`apt install zoxide`


# Note: Need to test this more. Can fail if env var does not get set write or if git is not installed!
# TODO: Write a script to do this 

`GITHUB_USERNAME=jgrowl sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:$GITHUB_USERNAME/dotfiles.git`

#`GITHUB_USERNAME='jgrowl' sh -c '~/.local/bin/chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git'`


## dependencies

### tmux

https://tmuxcheatsheet.com/

### chezmoi

https://www.chezmoi.io/

https://github.com/twpayne/chezmoi

### zim

https://zimfw.sh/


### fzf

### sesh

https://github.com/joshmedeski/sesh

inside zsh:  Ctrl+s

inside tmux: CTRL+b T


### Patched Nerd Fonts

Unzip .zip folder into ~/.local/share/fonts/

fc-list

https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip

https://www.nerdfonts.com/font-downloads

https://github.com/ryanoasis/nerd-fonts


### Spaceship prompt

https://github.com/spaceship-prompt/spaceship-prompt

