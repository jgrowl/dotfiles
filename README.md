# dotfiles 


# When you want to run ansible and don't want to jump into another tty. You'll need this because Privileges have been turned off for sway session
# This was primarily to make steam happy because the container thing complained that it was too open.

systemd-run --user -p NoNewPrivileges=no --pty /bin/bash



## Defaults, Keys, Assumptions

See sway config for bindings


## install debian >12

### lazy.nvim

### change sources.list to sid/unstable

`vi /etc/apt/sources.list`

    # Sid/unstable
    deb http://deb.debian.org/debian/ unstable main contrib non-free non-free-firmware
    deb-src http://deb.debian.org/debian/ unstable main contrib non-free


`apt update && upgrade`

## generate new ssh key

`ssh-keygen -t ed25519 -C "your_email@example.com"`

## install basic deps

`apt install git zoxide fzf`

env `GITHUB_USERNAME=jgrowl sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:$GITHUB_USERNAME/dotfiles.git`


## dependencies

### tpm

`mkdir -p ~/.tmux/plugins`
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

### powerline

`apt install powerline fonts-powerline`

###  Ulauncher

https://ulauncher.io/#Download
https://github.com/Ulauncher/Ulauncher/releases/tag/v6.0.0-beta19

### tmux

If catppuccin isn't loaded, then install by 

`Ctrl+B` then `I`

https://tmuxcheatsheet.com/

### go

https://go.dev/doc/install

### chezmoi

https://www.chezmoi.io/

https://github.com/twpayne/chezmoi

### zim

https://zimfw.sh/


### fzf

### sesh

You have to go to download a release on github or otherwise aquire it. Download, decompress, link in a ~/.local/.bin directory

https://github.com/joshmedeski/sesh

inside zsh:  Ctrl+s

inside tmux: CTRL+b T

### sway


# Can be used to verify 
systemctl --user show-environment | grep -E 'WAYLAND_DISPLAY|XDG_RUNTIME_DIR|SWAYSOCK'
journalctl --user -u sway-session.target -b
journalctl --user -u swayidle.service -b

systemctl --user disable --now swayidle.service || true
pkill -x swayidle || true
systemctl --user enable --now swayidle.service
journalctl --user -u swayidle.service -b -n 50
ps aux | grep '[s]wayidle'






Used to load sway as a user service, but if it ever crashed, I would be thrown back to a tty and would have to manually restart sway.
I wanted sway to just load automatically as it is primarily what I use. This meant that I had to turn the sway.service into a system level
service so that it could properly re-attach to the right tty. 

ansible installed system level sway-tty1.service
  -> runs sway-service executable
    -> starts sway-session.target
      -> waybar.service
      -> swayidle.service
         -> sway-start-swayidle.sh


# #
# 1) Produce group_vars/all.yml with your current manual packages
mkdir -p group_vars
apt-mark showmanual \
  | sort -u \
  | awk 'BEGIN{print "apt_packages:"} {print "  - " $0}' \
  > group_vars/all.yml





### swayidle & swaylock

systemctl --user daemon-reload
systemctl --user enable --now swayidle.service


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



