# About

## Conventions

* All .dotfiles in project root will be symlinked into $HOME via stow. All other files and folders will be ignored.

* All sensitive data should be stored in `private` directory which will also be linked via stow, but ignored by git.

# Installation

## Clone repo with libs

`git clone --recursive -j8 git@github.com:jgrowl/dotfiles.git`

## Restore private encrypted files

`./bin/restore`

## Link files into home

`./bin/stow`

# Backing up sensitive data

Data in `private` directory will be encrypted using duplicity and stored in DropBox folder. DropBox will handle syncing.

`./bin/restore`

# Staying up to date

`./bin/update`

# Components

## Pass

https://www.passwordstore.org/

## Oh My Zsh

https://github.com/robbyrussell/oh-my-zsh

### Added via

`git submodule add https://github.com/robbyrussell/oh-my-zsh.git lib/oh-my-zsh`

## SpaceVim

https://github.com/SpaceVim/SpaceVim

### Added via

`git submodule add https://github.com/SpaceVim/SpaceVim.git lib/SpaceVim`

## Generate gpg key

https://help.github.com/articles/generating-a-new-gpg-key/

`gpg --gen-key`

## Generate ssh keypair

https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/


# STUFF

brew tap caskroom/fonts
brew cask install font-hack-nerd-font

brew cask install font-dejavu-sans-mono-for-powerline font-dejavusansmono-nerd-font font-dejavusansmono-nerd-font-mono

brew install coreutils

## For clipboard inside of tmux
brew install reattach-to-user-namespace

# For making git use nvim buffer instead of trying to open another instance

pip3 install neovim-remote
