#!/bin/bash

# Update package lists
sudo apt update -y

sudo apt-get install -y build-essential bzip2
sudo apt install -y git curl

####
# Install Docker
####
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


####
# Useful tools (https://gist.github.com/MatteoGauthier/4ba0dfab5bfaf0013cd7402a4373dc4f)
# - fzf: A command-line fuzzy finder
# - lazydocker: A simple terminal UI for both docker and docker-compose
# - dua: Disk usage analyzer written in Rust
# - duf: Disk usage/Free utility
# - lazygit: A simple terminal UI for git commands
# - bat: A cat(1) clone with wings
####

sudo apt install -y fzf
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
curl -LSfs https://raw.githubusercontent.com/Byron/dua-cli/master/ci/install.sh | \
    sh -s -- --git Byron/dua-cli --target x86_64-unknown-linux-musl --crate dua --tag v2.29.0
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

sudo apt install -y duf
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
sudo apt install -y bat
rm -rf lazygit.tar.gz lazygit

echo "alias lg='lazygit'" >> ~/.bashrc

mkdir -p btop-install/output
wget -qO - https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz | tar -xj -C btop-install/output
(cd btop-install/output/btop && sudo make install && sudo make setuid)
rm -rf btop-install
