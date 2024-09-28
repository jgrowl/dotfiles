## Get chezmoi

`sh -c "$(curl -fsLS get.chezmoi.io)"`


## Make expected directories 

`mkdir -p ~/Code`


## Clone repo with libs from SSH or HTTP

`git clone --recursive -j8 git@github.com:jgrowl/dotfiles.git`

or

`git clone --recursive -j8 https://github.com/jgrowl/dotfiles.git`


## Symlink to expected directory

`ln -s ~/Code/dotfiles ~/.local/share/chezmoi`

## Apply 

`~/bin/chezmoi apply -v`
