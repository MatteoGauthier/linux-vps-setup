#!/bin/bash

# Update package lists
sudo apt update -y

sudo apt-get install -y build-essential bzip2
sudo apt install -y git curl

####
# Install Docker
####
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

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
    sh -s -- --git Byron/dua-cli --target aarch64-unknown-linux-musl --crate dua --tag v2.29.0
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
export PATH="$HOME/.cargo/bin:$PATH"
dua

sudo apt install -y duf
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
sudo apt install -y bat
rm -rf lazygit.tar.gz lazygit

echo "alias lg='lazygit'" >> ~/.bashrc

mkdir -p btop-install/output
wget -qO - https://github.com/aristocratos/btop/releases/latest/download/btop-aarch64-linux-musl.tbz | tar -xj -C btop-install/output
(cd btop-install/output/btop && sudo make install && sudo make setuid)
rm -rf btop-install

echo "alias hyfetch='bash <(curl -sL nf.hydev.org)'" >> ~/.bashrc

####
# Add git aliases to .gitconfig
####
git config --global alias.s status
git config --global alias.a '!git add . && git status'
git config --global alias.au '!git add -u . && git status'
git config --global alias.aa '!git add . && git add -u . && git status'
git config --global alias.c commit
git config --global alias.cm 'commit -m'
git config --global alias.ca 'commit --amend # careful'
git config --global alias.cam 'commit -a -m # careful'
git config --global alias.ac '!git add . && git commit'
git config --global alias.acm '!git add . && git commit -m'
git config --global alias.l 'log --graph --all --pretty=format:"%C(yellow)%h%C(cyan)%d%Creset %s %C(white)- %an, %ar%Creset"'
git config --global alias.ll 'log --stat --abbrev-commit'
git config --global alias.lg 'log --color --graph --pretty=format:"%C(bold white)%h%Creset -%C(bold green)%d%Creset %s %C(bold green)(%cr)%Creset %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
git config --global alias.llg 'log --color --graph --pretty=format:"%C(bold white)%H %d%Creset%n%s%n%+b%C(bold blue)%an <%ae>%Creset %C(bold green)%cr (%ci)" --abbrev-commit'
git config --global alias.lllg 'log --graph --decorate --all --topo-order --date=format-local:"%Y-%m-%d %H:%M:%S" --pretty=format:"%C(cyan)%h%Creset %C(black bold)%ad%Creset%C(auto)%d %s"'
git config --global alias.ai '!bun run /Users/matteogauthier/dev/quick-commit-ai/quick-commit-ai.ts'

git config --global alias.d diff
git config --global alias.master 'checkout master'
git config --global alias.develop 'checkout develop'
git config --global alias.prod 'checkout prod'
git config --global alias.staging 'checkout staging'
git config --global alias.main 'checkout main'
git config --global alias.spull 'svn rebase'
git config --global alias.spush 'svn dcommit'
git config --global alias.alias '!git config --list | grep "alias\." | sed "s/alias\\.\\([^=]*\\)=\\(.*\\)/\\1\\\t => \\2/" | sort'
git config --global alias.remotes 'remote -v'
git config --global alias.co checkout
git config --global alias.check checkout
git config --global alias.ch checkout
git config --global alias.cob 'checkout -b'
git config --global alias.po 'pull origin'
git config --global alias.pu '!git push origin $(git branch --show-current)'
git config --global alias.rocket '!git push origin $(git branch --show-current)'
git config --global alias.branchlog '!git for-each-ref --sort=committerdate refs/heads --format="%(authordate:short) %(color:red)%(objectname:short) %(color:yellow)%(refname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset))"'
git config --global alias.branchlog-desc '!git for-each-ref --sort=-committerdate refs/heads --format="%(authordate:short) %(color:red)%(objectname:short) %(color:yellow)%(refname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset))"'
git config --global alias.stats '!git --no-pager shortlog -s -n --all --no-merges'
git config --global alias.statsbranch '!git --no-pager shortlog -s -n --no-merges'
git config --global alias.statsloc '!git ls-files | while read f; do git blame -w -M -C -C --line-porcelain "$f" | grep -I "^author "; done | sort -f | uniq -ic | sort -n --reverse'
git config --global alias.difforigin '!git diff origin/$(git branch --show-current)'
git config --global alias.save-stash '!git stash show "stash@{0}" -p > stash_0.patch'
git config --global alias.stash-name '!echo "./$(git stash list --format="%B" -n 1)"'

source ~/.bashrc
