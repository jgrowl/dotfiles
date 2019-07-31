# About

## Conventions

* All .dotfiles in project root will be symlinked into $HOME via stow. All other files and folders will be ignored.

* All sensitive data should be stored in `private` directory which will also be linked via stow, but ignored by git.

# Installation

## Install deps

`brew tap discoteq/discoteq`

`brew install coreutils greadlink flock`

### For clipboard inside of tmux

`brew install reattach-to-user-namespace`

### Fonts

`brew tap caskroom/fonts`

`brew cask install font-hack-nerd-font font-dejavu-sans-mono-for-powerline font-dejavusansmono-nerd-font font-dejavusansmono-nerd-font-mono`


## Clone repo with libs from HTTP

`git clone --recursive -j8 https://github.com/jgrowl/dotfiles.git`


## Restore private encrypted files

`./bin/restore`

## Link files into home

`./bin/stow`

# Backing up sensitive data

Data in `private` directory will be encrypted using duplicity and stored in synced folder.

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



# For making git use nvim buffer instead of trying to open another instance
# Source: https://github.com/mhinz/neovim-remote

pip3 install neovim-remote

# For vint

`pip install vim-vint`
