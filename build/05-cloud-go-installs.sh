#!/usr/bin/env bash

set -eoux pipefail

# Builder stage only (see Containerfile): compile the cloud-specific Go tools and
# kics here. The final image copies just the resulting binaries via
# COPY --from=builder, so the golang toolchain and build leftovers never ship.
# (brutespray and John the Ripper are built in 00-go-installs.sh, not here.)

apt update
DEBIAN_FRONTEND=noninteractive apt -y install \
    golang git make build-essential libssl-dev libpcap-dev zlib1g-dev pkg-config

# cloudfox
go install github.com/BishopFox/cloudfox@latest
install -o root -g root -m 0755 /root/go/bin/cloudfox /usr/local/bin/cloudfox

# aws-enumerator
GOPATH=/opt/aws-enumerator go install -v github.com/shabarkin/aws-enumerator@latest
install -o root -g root -m 0755 /opt/aws-enumerator/bin/aws-enumerator /usr/local/bin/aws-enumerator

# GoAWSConsoleSpray
GOPATH=/opt/GoAWSConsoleSpray go install github.com/WhiteOakSecurity/GoAWSConsoleSpray@latest
install -o root -g root -m 0755 /opt/GoAWSConsoleSpray/bin/GoAWSConsoleSpray /usr/local/bin/GoAWSConsoleSpray

# kics (keep only the binary + query assets the runtime needs)
git clone --depth 1 https://github.com/Checkmarx/kics.git /opt/kics
cd /opt/kics
go mod vendor
make build
install -o root -g root -m 0755 /opt/kics/bin/kics /usr/local/bin/kics
rm -rf /opt/kics/vendor /opt/kics/.git /opt/kics/bin
