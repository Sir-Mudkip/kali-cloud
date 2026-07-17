#!/usr/bin/env bash

set -eoux pipefail

PACKAGES=(
    curl
    fzf
    gpg
    git
    jq
    metasploit-framework
    neovim
    tmux
    ncat
    netexec
    netdiscover
    net-tools
    iproute2
    iputils-ping
    peass
    nmap
    tcpdump
    wget2
    python3
    python3-venv
    xz-utils
    python3-boto3
    unzip
    powershell
    locales
    pipx
    ruby
    npm
)

# install packages
apt update
apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt -y install "${PACKAGES[@]}"
rm -rd /var/lib/apt/lists/*
