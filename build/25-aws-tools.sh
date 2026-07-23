#!/usr/bin/env bash

set -eoux pipefail

# AWS cloud-pentest / cloud-audit tooling. gcloud / GCP tooling is intentionally
# omitted. Compiled cloud Go tools (cloudfox, aws-enumerator, GoAWSConsoleSpray)
# are built in the builder stage (build/00-go-installs.sh) and pulled in via
# COPY --from=builder.

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/opt/awscliv2.zip"
unzip /opt/awscliv2.zip -d /opt/
/opt/aws/install
rm -rf /opt/aws
rm /opt/awscliv2.zip

# aws session manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/opt/session-manager-plugin.deb"
dpkg -i /opt/session-manager-plugin.deb
rm /opt/session-manager-plugin.deb

# pmapper
pipx install git+https://github.com/mosesrenegade/PMapper

# cloudsplaining
pipx install cloudsplaining

# pacu (needs a C compiler to build native deps; purge it in this same layer
# afterwards so the ~150MB toolchain isn't left in the shipped image)
apt update
DEBIAN_FRONTEND=noninteractive apt install -y gcc-12 g++-12
pipx install pacu
apt-get purge -y gcc-12 g++-12
apt-get autoremove -y
rm -rd /var/lib/apt/lists/*

# s3-account-search
pipx install s3-account-search

# snotra aws
pipx install git+https://gitlab.com/snotra.cloud/aws.git

# taws
curl -sL https://github.com/huseyinbabal/taws/releases/latest/download/taws-x86_64-unknown-linux-musl.tar.gz | tar xz -C /opt
mv /opt/taws /usr/local/bin/
