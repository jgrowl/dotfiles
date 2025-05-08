export NEOVIM_FILE='nvim-linux-x86_64.tar.gz'
export NEOVIM_URL="https://github.com/neovim/neovim/releases/latest/download/$NEOVIM_FILE"
sh -c 'echo Downloading NeoVim from $NEOVIM_URL'

sh -c 'curl -LO $NEOVIM_URL'
rm -rf /opt/nvim
sh -c 'tar -vC /opt -xzf $NEOVIM_FILE'
