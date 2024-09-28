= dotfiles =


## Clone repo with libs from HTTP

`git clone --recursive -j8 https://github.com/jgrowl/dotfiles.git`


= dependencies =

== chezmoi ==

My chezmoi config! There is no chezmoi package in debian because of how they frequently release binaries using go.

`sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jgrowl`

https://www.chezmoi.io/

https://github.com/twpayne/chezmoi

## Oh My Zsh

https://github.com/robbyrussell/oh-my-zsh

### Added via

`git submodule add https://github.com/robbyrussell/oh-my-zsh.git lib/oh-my-zsh`
