#!/bin/bash
set -ex

# Install pkgs
apt-get update
apt-get install -y ca-certificates curl gnupg2 iputils-ping dnsutils lrzsz
apt-get install -y ascii xxd
apt-get install -y vim tmux git-lfs clang-format apache2-utils

# Install kernel build tools
apt-get install -y flex bc libelf-dev libssl-dev bison

# Install build
# apt-get install -y ccache distcc clang llvm

# Install android tools adb
# apt-get install -y adb

# system language
# graphviz use for golang pprof
apt-get install -y golang graphviz
# remove golang precompiled .a files
rm -rf `/usr/bin/go env GOROOT`/pkg/linux_amd64

apt-get install -y python3 supervisor

# client utils
apt-get install -y redis-tools mariadb-client etcd-client

# sshd
apt-get install -y openssh-server
echo "AcceptEnv SHELL_OS LC_*" > /etc/ssh/sshd_config.d/devcontainer.conf

# zsh utils 命令行终端
apt-get install -y autojump fzf
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /usr/local/bin/zsh-install.sh && chmod a+x /usr/local/bin/zsh-install.sh
export ZSH="/opt/oh-my-zsh" && export CHSH=no && zsh-install.sh
export ZSH_CUSTOM=${ZSH}/custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/zsh-autosuggestions

# Vim
git clone https://github.com/VundleVim/Vundle.vim.git /opt/vim/bundle/Vundle.vim
cd /opt/vim/bundle
grep Plugin /opt/root/.vimrc.bundles|grep -v '"'|grep -v "Vundle"|awk -F "'" '{print $2}'|xargs -L1 git clone

# RUN echo "dash dash/sh boolean false" | debconf-set-selections
# RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install Docker
curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null
echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install -y docker-ce-cli
rm -rf /etc/apt/sources.list.d/docker.list

cd /tmp
# Install direnv
DIRENV_VERSION=v2.34.0
wget -q https://github.com/direnv/direnv/releases/download/${DIRENV_VERSION}/direnv.linux-amd64
mv direnv.linux-amd64 /usr/local/bin/direnv && chmod a+x /usr/local/bin/direnv && direnv --version

# Install skopeo
SKOPEO_VERSION=v1.13.2
wget -q https://github.com/lework/skopeo-binary/releases/download/${SKOPEO_VERSION}/skopeo-linux-amd64
mv skopeo-linux-amd64 /usr/local/bin/skopeo && chmod a+x /usr/local/bin/skopeo && skopeo --version

# Install NodeJS
NODEJS_VERSION=v20.17.0
wget -q https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.xz
tar -xf node-${NODEJS_VERSION}-linux-x64.tar.xz
mv node-${NODEJS_VERSION}-linux-x64 /opt/node
ln -sf /opt/node/bin/node /usr/local/bin/
ln -sf /opt/node/bin/npm /usr/local/bin/
# 全局配置
echo "prefix=/root/.npm-packages" > /opt/node/lib/node_modules/npm/npmrc

# https://github.com/restic/restic
RESTIC_VERSION=0.16.0
wget -q https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2
bunzip2 restic_${RESTIC_VERSION}_linux_amd64.bz2
chmod a+x restic_${RESTIC_VERSION}_linux_amd64 && mv restic_${RESTIC_VERSION}_linux_amd64 /usr/local/bin/restic

# https://github.com/rclone/rclone
RCLONE_VERSION=v1.63.1
wget -q https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.deb
dpkg -i rclone-${RCLONE_VERSION}-linux-amd64.deb

# Install Helm
# https://github.com/helm/helm
HELM_VERSION=v3.12.2
wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -xf helm-${HELM_VERSION}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
mkdir -p ${ZSH_CUSTOM}/helm-autocomplete
helm completion zsh > ${ZSH_CUSTOM}/helm-autocomplete/helm-autocomplete.plugin.zsh

# Install Kubectl
# https://github.com/kubernetes/kubernetes
KUBECTL_VERSION=v1.22.17
wget -q https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod a+x kubectl && mv kubectl /usr/local/bin/
mkdir -p ${ZSH_CUSTOM}/kubectl-autocomplete
kubectl completion zsh > ${ZSH_CUSTOM}/kubectl-autocomplete/kubectl-autocomplete.plugin.zsh

# Install grpcurl
GPRCCURL_VERSION=1.8.7
wget -q https://github.com/fullstorydev/grpcurl/releases/download/v${GPRCCURL_VERSION}/grpcurl_${GPRCCURL_VERSION}_linux_x86_64.tar.gz
tar -xf grpcurl_${GPRCCURL_VERSION}_linux_x86_64.tar.gz
mv grpcurl /usr/local/bin/

# Install protoc
export PROTOC_VERSION=24.1
wget -q https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
unzip -o protoc-${PROTOC_VERSION}-linux-x86_64.zip
mkdir -p /opt/go/bin
mv bin/protoc /opt/go/bin/ && /opt/go/bin/protoc --version
mv include /opt/go/

# Install python uv
export UV_VERSION=0.4.17
wget -q https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz
tar -xf uv-x86_64-unknown-linux-gnu.tar.gz
mv uv-x86_64-unknown-linux-gnu/* /usr/local/bin

# Clean up
mkdir -p /data/repos /data/pub /data/logs /data/etc/supervisord

apt-get -y autoremove
apt-get -y clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
