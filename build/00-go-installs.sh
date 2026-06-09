#!/usr/bin/env bash

set -eoux pipefail

# Builder stage only (see Containerfile): compile the Go tools and John the
# Ripper here. The final image copies just the resulting binaries via
# COPY --from=builder, so the golang toolchain and build leftovers never ship.

apt update
DEBIAN_FRONTEND=noninteractive apt -y install \
    golang git make build-essential libssl-dev libpcap-dev zlib1g-dev pkg-config

# brutespray
go install github.com/x90skysn3k/brutespray@latest
install -o root -g root -m 0755 /root/go/bin/brutespray /usr/local/bin/brutespray

# gowitness
go install github.com/sensepost/gowitness@latest
install -o root -g root -m 0755 /root/go/bin/gowitness /usr/local/bin/gowitness

# wpprobe
go install github.com/Chocapikk/wpprobe@latest
install -o root -g root -m 0755 /root/go/bin/wpprobe /usr/local/bin/wpprobe

# gobuster
go install github.com/OJ/gobuster/v3@latest
install -o root -g root -m 0755 /root/go/bin/gobuster /usr/local/bin/gobuster

# nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
install -o root -g root -m 0755 /root/go/bin/nuclei /usr/local/bin/nuclei

# ldapnomnom
go install github.com/lkarlslund/ldapnomnom@latest
install -o root -g root -m 0755 /root/go/bin/ldapnomnom /usr/local/bin/ldapnomnom

# traitor
go install github.com/liamg/traitor/cmd/traitor@latest
install -o root -g root -m 0755 /root/go/bin/traitor /usr/local/bin/traitor

# go-windapsearch
git clone https://github.com/ropnop/go-windapsearch.git && cd go-windapsearch
go install github.com/magefile/mage@latest
/root/go/bin/mage build
install -o root -g root -m 0755 windapsearch /usr/local/bin/windapsearch

