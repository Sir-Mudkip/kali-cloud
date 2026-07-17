#!/usr/bin/env bash

set -eoux pipefail

PACKAGES=(
    curl
<<<<<<< HEAD
    default-mysql-client
    dnschef
    dnsrecon
    dnsutils
    dos2unix
    driftnet
    dsniff
    eaphammer
    eapmd5pass
    enum4linux
    evil-ssdp
    evil-winrm
    exploitdb
    ffuf
    file
    finger
    fping
    ftp-ssl
    fuse
||||||| parent of d446db1 (new build, stripped everything down to more minimal tools)
    default-mysql-client
    dirb
    dnschef
    dnsrecon
    dnsutils
    dos2unix
    driftnet
    dsniff
    eaphammer
    eapmd5pass
    enum4linux
    evil-ssdp
    evil-winrm
    exploitdb
    ffuf
    file
    finger
    fping
    ftp-ssl
    fuse
=======
>>>>>>> d446db1 (new build, stripped everything down to more minimal tools)
    fzf
    gpg
    git
    jq
    metasploit-framework
    neovim
<<<<<<< HEAD
    netexec
||||||| parent of d446db1 (new build, stripped everything down to more minimal tools)
=======
    tmux
    ncat
    netexec
>>>>>>> d446db1 (new build, stripped everything down to more minimal tools)
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
