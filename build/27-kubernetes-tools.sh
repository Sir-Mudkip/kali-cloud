#!/usr/bin/env bash

set -eoux pipefail

# Kubernetes cloud-pentest / cloud-audit tooling. Runs after
# build/26-azure-tools.sh so the `az` CLI is available for `az aks install-cli`
# (kubelogin). krew-based plugins install after kubectl-krew is on PATH.

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

# azure kubelogin (needs the az CLI installed in build/26-azure-tools.sh)
az aks install-cli

# kubernetes-rbac-audit
git clone --depth 1 "https://github.com/PalindromeLabs/kubernetes-rbac-audit" /opt/kubernetes-rbac-audit
python3 -m venv /opt/kubernetes-rbac-audit/venv
/opt/kubernetes-rbac-audit/venv/bin/pip install --no-cache-dir colorama

# kubenumerate
git clone --depth 1 "https://github.com/0x5ubt13/kubenumerate" /opt/kubenumerate
python3 -m venv /opt/kubenumerate/venv
/opt/kubenumerate/venv/bin/pip install --no-cache-dir -r /opt/kubenumerate/requirements.txt
echo "alias kubenumerate=\"/opt/kubenumerate/venv/bin/python /opt/kubenumerate/kubenumerate.py\"" >/root/.bashrc.d/kubenumerate.rc

# kubiscan
git clone --depth 1 "https://github.com/cyberark/KubiScan" /opt/KubiScan
python3 -m venv /opt/KubiScan/venv
/opt/KubiScan/venv/bin/pip install --no-cache-dir -r /opt/KubiScan/requirements.txt
echo "alias KubiScan=\"/opt/KubiScan/venv/bin/python /opt/KubiScan/KubiScan.py\"" >/root/.bashrc.d/KubiScan.rc

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

# snotra kubernetes
git clone --depth 1 "https://gitlab.com/snotra.cloud/kubernetes.git" /opt/snotra_kubernetes
python3 -m venv /opt/snotra_kubernetes/venv
/opt/snotra_kubernetes/venv/bin/pip install --no-cache-dir -r /opt/snotra_kubernetes/requirements.txt
echo "alias snotra_kubernetes=\"/opt/snotra_kubernetes/venv/bin/python /opt/snotra_kubernetes/snotra.py\"" >/root/.bashrc.d/snotra_kubernetes.rc
