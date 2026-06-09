#!/usr/bin/env bash

set -eoux pipefail

PACKAGES=(
    above
    aircrack-ng
    airgeddon
    antiword
    apt-utils
    arp-scan
    bettercap
    binwalk
    bloodhound-ce-python
    bloodhound.py
    bruteshark
    bsdmainutils
    build-essential
    bully
    certipy-ad
    cewl
    changeme
    chisel
    coercer
    cowpatty
    cpanminus
    crowbar
    curl
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
    fzf
    g++
    gcc
    git
    gitleaks
    gpg
    groff-base
    hcxdumptool
    hcxtools
    heimdal-clients
    hostapd
    hostapd-mana
    hostapd-wpe
    htop
    humble
    hydra
    ike-scan
    iproute2
    iputils-ping
    john
    jq
    kmod
    krb5-user
    lapsdumper
    laudanum
    ldapscripts
    libgtk-3-dev
    libimage-exiftool-perl
    libkrb5-dev
    libnss-myhostname
    libpng-dev
    libqrencode-dev
    libssl-dev
    ligolo-ng
    locales
    macchanger
    make
    man
    medusa
    metasploit-framework
    mimikatz
    mingw-w64
    mitm6
    mono-devel
    nbtscan-unixwiz
    ncat
    neovim
    netdiscover
    net-tools
    nfs-common
    nikto
    nishang
    nmap
    npm
    ntpsec-ntpdate
    odat
    open-iscsi
    openjdk-25-jre
    openssh-server
    openssl
    pciutils
    peass
    pipx
    pixiewps
    pkexec
    pkg-config
    postgresql
    postgresql-client
    powercat
    powershell
    powersploit
    procps
    proxify
    proxychains4
    pskracker
    psmisc
    pwncat
    python2
    python3
    python3-impacket
    python3-ldapdomaindump
    python3-lsassy
    python3-pip
    python3-pyfiglet
    python3-pypykatz
    python3-pywerview
    python3-venv
    reaver
    redis-tools
    responder
    ridenum
    ripgrep
    rlwrap
    rpcbind
    rsync
    rusers
    sipcalc
    smbmap
    snmp
    snmp-mibs-downloader
    software-properties-common
    spray
    spraykatz
    sqlmap
    sshfs
    sshuttle
    sslscan
    strongswan
    swaks
    systemd
    tcpdump
    telnet
    tesseract-ocr
    tftp-hpa
    thc-ipv6
    thc-pptp-bruter
    theharvester
    tig
    tnftp
    tnscmd10g
    tree
    trivy
    trufflehog
    tshark
    unzip
    wfuzz
    wget2
    wifiphisher
    wifite
    windows-binaries
    wl-clipboard
    wmis
    wordlistraider
    wpasupplicant
    wpscan
    xq
    yersinia
    python3-boto3
)

# install packages
apt update
apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt -y install "${PACKAGES[@]}"
rm -rd /var/lib/apt/lists/*

# docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian trixie stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update
DEBIAN_FRONTEND=noninteractive apt -y install \
    docker-ce docker-ce-cli containerd.io docker-compose-plugin
rm -rd /var/lib/apt/lists/*
mkdir -p /etc/docker
echo '{"storage-driver": "vfs"}' | tee /etc/docker/daemon.json

