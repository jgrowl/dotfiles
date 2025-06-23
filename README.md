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


### Audio stuff

#### Search for sink

`pactl list | less`

or

`pactl list | grep game`

#### Set sink id

pactl set-default-sink 56

#### Set volume

pactl set-sink-volume 56 100%


#### GPU Passthrough notes

0e:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 33 [Radeon RX 7600/7600 XT/7600M XT/7600S/7700S / PRO W7600] [1002:7480] (rev cf)



0f:00.0 VGA compatible controller [0300]: NVIDIA Corporation AD104 [GeForce RTX 4070 Ti] [10de:2782] (rev a1)

0f:00.1 Audio device [0403]: NVIDIA Corporation AD104 High Definition Audio Controller [10de:22bc] (rev a1)

Put these ids in
/etc/modprobe.d/vfio.conf



