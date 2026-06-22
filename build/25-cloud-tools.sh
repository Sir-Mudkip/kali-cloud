#!/usr/bin/env bash

set -eoux pipefail

# Cloud-pentest / cloud-audit tooling (AWS, Azure, Kubernetes, OCI, multi-cloud).
# Mirrors the cloud subset of the reference build's manual installs. gcloud / GCP
# tooling is intentionally omitted. Compiled cloud Go tools + kics are built in the
# builder stage (build/05-cloud-go-installs.sh) and pulled in via COPY --from=builder.

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/opt/awscliv2.zip"
unzip /opt/awscliv2.zip -d /opt/
/opt/aws/install
rm -rf /opt/aws
rm /opt/awscliv2.zip

# azure cli (azure-cli is the package that ships the `az` app; az-cli is only a wrapper with no apps)
pipx install azure-cli
pipx inject azure-cli setuptools
## bash completion
curl -o "/root/.az.completion" "https://raw.githubusercontent.com/Azure/azure-cli/refs/heads/main/az.completion"

# aws session manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/opt/session-manager-plugin.deb"
dpkg -i /opt/session-manager-plugin.deb
rm /opt/session-manager-plugin.deb

# kubectl
curl -fsL "https://dl.k8s.io/release/$(curl -fsL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o "/opt/kubectl"
install -o root -g root -m 0755 /opt/kubectl /usr/local/bin/kubectl
rm /opt/kubectl

# krew
wget "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" -O /opt/krew-linux_amd64.tar.gz
tar -xzf /opt/krew-linux_amd64.tar.gz -C /opt/
/opt/krew-linux_amd64 install krew
install -o root -g root -m 0755 "$HOME"/.krew/bin/kubectl-krew /usr/local/bin/kubectl-krew
rm /opt/krew-*

# kubesec-scan
kubectl-krew install kubesec-scan

# access_matrix
kubectl-krew install access-matrix

# score
kubectl-krew install score

# roadtools
pipx install roadrecon

# pmapper
pipx install git+https://github.com/mosesrenegade/PMapper

# checkov
pipx install checkov

# prowler
pipx install prowler

# cloudsplaining
pipx install cloudsplaining

# scoutsuite
pipx install git+https://github.com/nccgroup/ScoutSuite

# pacu
apt update
DEBIAN_FRONTEND=noninteractive apt install -y gcc-12 g++-12
rm -rd /var/lib/apt/lists/*
pipx install pacu

# s3-account-search
pipx install s3-account-search

# iamactionhunter
pipx install iamactionhunter

# az powershell
pwsh -c "Install-Module -Name Az -Repository PSGallery -Force"

# ms graph powershell
pwsh -c "Install-Module -Name Microsoft.Graph -Repository PSGallery -Force"

# blackcat
git clone --depth 1 "https://github.com/azurekid/blackcat" /opt/blackcat

# kubernetes-rbac-audit
git clone --depth 1 "https://github.com/PalindromeLabs/kubernetes-rbac-audit" /opt/kubernetes-rbac-audit
python3 -m venv /opt/kubernetes-rbac-audit/venv
/opt/kubernetes-rbac-audit/venv/bin/pip install --no-cache-dir colorama

# kubenumerate
git clone --depth 1 "https://github.com/0x5ubt13/kubenumerate" /opt/kubenumerate
python3 -m venv /opt/kubenumerate/venv
/opt/kubenumerate/venv/bin/pip install --no-cache-dir -r /opt/kubenumerate/requirements.txt
echo "alias kubenumerate=\"/opt/kubenumerate/venv/bin/python /opt/kubenumerate/kubenumerate.py\"" >/root/.bashrc.d/kubenumerate.rc

# cloud_enum
pipx install git+https://github.com/initstring/cloud_enum

# azure kubelogin
az aks install-cli

# kubiscan
git clone --depth 1 "https://github.com/cyberark/KubiScan" /opt/KubiScan
python3 -m venv /opt/KubiScan/venv
/opt/KubiScan/venv/bin/pip install --no-cache-dir -r /opt/KubiScan/requirements.txt
echo "alias KubiScan=\"/opt/KubiScan/venv/bin/python /opt/KubiScan/KubiScan.py\"" >/root/.bashrc.d/KubiScan.rc

# graphpython
pipx install git+https://github.com/mlcsec/Graphpython

# kubeaudit
wget2 "https://github.com/Shopify/kubeaudit/releases/download/v0.22.1/kubeaudit_0.22.1_linux_amd64.tar.gz" -O /opt/kubeaudit_0.22.1_linux_amd64.tar.gz
tar -xzf /opt/kubeaudit_0.22.1_linux_amd64.tar.gz -C /opt/
install -o root -g root -m 0755 /opt/kubeaudit /usr/local/bin/kubeaudit
rm /opt/kubeaudit_0.22.1_linux_amd64.tar.gz
rm /opt/kubeaudit

# nodeshell
kubectl-krew install node-shell
install -o root -g root -m 0755 "$HOME"/.krew/bin/kubectl-node_shell /usr/local/bin/kubectl-node_shell

# kubeletctl
wget -q https://github.com/cyberark/kubeletctl/releases/download/v1.13/kubeletctl_linux_amd64 -O /opt/kubeletctl
install -o root -g root -m 0755 /opt/kubeletctl /usr/local/bin/kubeletctl
rm /opt/kubeletctl

# iam policy visualize
git clone --depth 1 "https://github.com/hac01/iam-policy-visualize" /opt/iam-policy-visualize
python3 -m venv /opt/iam-policy-visualize/venv
/opt/iam-policy-visualize/venv/bin/pip install --no-cache-dir graphviz
echo "alias iam-policy-visualize=\"/opt/iam-policy-visualize/venv/bin/python /opt/iam-policy-visualize/main.py\"" >/root/.bashrc.d/iam-policy-visualize.rc

# noprompt
git clone --depth 1 "https://github.com/NotSoSecure/NoPrompt" /opt/NoPrompt
python3 -m venv /opt/NoPrompt/venv
/opt/NoPrompt/venv/bin/pip install --no-cache-dir -r /opt/NoPrompt/requirements.txt
echo "alias noprompt=\"/opt/NoPrompt/venv/bin/python /opt/NoPrompt/noprompt.py\"" >/root/.bashrc.d/noprompt.rc

# cloudsploit
git clone --depth 1 "http://github.com/aquasecurity/cloudsploit.git" /opt/cloudsploit
cd /opt/cloudsploit
npm install --omit=dev
npm cache clean --force
chmod +x /opt/cloudsploit/index.js

# noCAP
git clone --depth 1 "https://github.com/securesloth/noCAP" /opt/noCAP
python3 -m venv /opt/noCAP/venv
/opt/noCAP/venv/bin/pip install --no-cache-dir -r /opt/noCAP/requirements.txt
echo "alias noCAP=\"/opt/noCAP/venv/bin/python /opt/noCAP/noCAP.py\"" >/root/.bashrc.d/noCAP.rc

# caReports
git clone --depth 1 "https://github.com/uniQuk/caReports" /opt/caReports

# CAPs
git clone --depth 1 "https://github.com/techBrandon/CAPs" /opt/CAPs

# EntraFalcon
git clone --depth 1 "https://github.com/CompassSecurity/EntraFalcon" /opt/EntraFalcon

# grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# snotra kubernetes
git clone --depth 1 "https://gitlab.com/snotra.cloud/kubernetes.git" /opt/snotra_kubernetes
python3 -m venv /opt/snotra_kubernetes/venv
/opt/snotra_kubernetes/venv/bin/pip install --no-cache-dir -r /opt/snotra_kubernetes/requirements.txt
echo "alias snotra_kubernetes=\"/opt/snotra_kubernetes/venv/bin/python /opt/snotra_kubernetes/snotra.py\"" >/root/.bashrc.d/snotra.rc

# snotra aws
git clone --depth 1 "https://gitlab.com/snotra.cloud/aws.git" /opt/snotra_aws
python3 -m venv /opt/snotra_aws/venv
/opt/snotra_aws/venv/bin/pip install --no-cache-dir -r /opt/snotra_aws/requirements.txt
echo "alias snotra_aws=\"/opt/snotra_aws/venv/bin/python /opt/snotra_aws/snotra.py\"" >>/root/.bashrc.d/snotra.rc

# snotra azure
git clone --depth 1 "https://gitlab.com/snotra.cloud/azure.git" /opt/snotra_azure
python3 -m venv /opt/snotra_azure/venv
/opt/snotra_azure/venv/bin/pip install --no-cache-dir -r /opt/snotra_azure/requirements.txt
echo "alias snotra_azure=\"/opt/snotra_azure/venv/bin/python /opt/snotra_azure/snotra.py\"" >>/root/.bashrc.d/snotra.rc

# taws
curl -sL https://github.com/huseyinbabal/taws/releases/latest/download/taws-x86_64-unknown-linux-musl.tar.gz | tar xz -C /opt
mv /opt/taws /usr/local/bin/

# zizmor (upstream release artifact name; x86_64 build for this amd64 image)
curl -sL https://github.com/zizmorcore/zizmor/releases/download/v1.22.0/zizmor-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /opt
mv /opt/zizmor /usr/local/bin/

# azqr
latest_azqr=$(curl -sL https://api.github.com/repos/Azure/azqr/releases/latest | jq -r ".tag_name" | cut -c1-)
wget https://github.com/Azure/azqr/releases/download/"$latest_azqr"/azqr-linux-amd64.zip -O /opt/azqr.zip
unzip -uj -qq /opt/azqr.zip -d /opt
install -o root -g root -m 0755 /opt/azqr /usr/local/bin/azqr
rm /opt/azqr.zip
rm /opt/azqr
