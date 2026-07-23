#!/usr/bin/env bash

set -eoux pipefail

# Builder stage only (see Containerfile): compile the Go tools (nuclei plus the
# cloud Go tools and kics) here. The final image copies just the resulting
# binaries via COPY --from=builder, so the golang toolchain and build leftovers
# never ship. All builds pass `-ldflags=-s -w` to strip the symbol table and
# DWARF debug info, which cuts the shipped binaries by ~25-30%.

apt update
DEBIAN_FRONTEND=noninteractive apt -y install \
    golang git make build-essential libssl-dev libpcap-dev zlib1g-dev pkg-config

# nuclei
go install -v -ldflags="-s -w" github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
install -o root -g root -m 0755 /root/go/bin/nuclei /usr/local/bin/nuclei

# cloudfox
go install -ldflags="-s -w" github.com/BishopFox/cloudfox@latest
install -o root -g root -m 0755 /root/go/bin/cloudfox /usr/local/bin/cloudfox

# Ffuf for fuzzing
go install -v -ldflags="-s -w" github.com/ffuf/ffuf/v2@latest
install -o root -g root -m 0755 /root/go/bin/ffuf /usr/local/bin/ffuf

# aws-enumerator
GOPATH=/opt/aws-enumerator go install -v -ldflags="-s -w" github.com/shabarkin/aws-enumerator@latest
install -o root -g root -m 0755 /opt/aws-enumerator/bin/aws-enumerator /usr/local/bin/aws-enumerator

# GoAWSConsoleSpray
GOPATH=/opt/GoAWSConsoleSpray go install -ldflags="-s -w" github.com/WhiteOakSecurity/GoAWSConsoleSpray@latest
install -o root -g root -m 0755 /opt/GoAWSConsoleSpray/bin/GoAWSConsoleSpray /usr/local/bin/GoAWSConsoleSpray

# kics (keep only the binary + query assets the runtime needs). kics' Makefile
# bakes a version string into its own ldflags, so strip the built binary instead
# of overriding LDFLAGS.
git clone --depth 1 https://github.com/Checkmarx/kics.git /opt/kics
cd /opt/kics
go mod vendor
make build
strip /opt/kics/bin/kics
install -o root -g root -m 0755 /opt/kics/bin/kics /usr/local/bin/kics
rm -rf /opt/kics/vendor /opt/kics/.git /opt/kics/bin
