#!/usr/bin/env bash

set -eoux pipefail

# Azure / Entra ID cloud-pentest / cloud-audit tooling. gcloud / GCP tooling is
# intentionally omitted. Runs before build/27-kubernetes-tools.sh so the `az` CLI
# is present when that script runs `az aks install-cli` (kubelogin).

# azure cli (azure-cli is the package that ships the `az` app; az-cli is only a wrapper with no apps)
pipx install azure-cli
pipx inject azure-cli setuptools
## bash completion
curl -o "/root/.az.completion" "https://raw.githubusercontent.com/Azure/azure-cli/refs/heads/main/az.completion"

# roadtools
pipx install roadrecon

# az powershell
pwsh -c "Install-Module -Name Az -Repository PSGallery -Force"

# ms graph powershell
pwsh -c "Install-Module -Name Microsoft.Graph -Repository PSGallery -Force"

# noprompt
git clone --depth 1 "https://github.com/NotSoSecure/NoPrompt" /opt/NoPrompt
python3 -m venv /opt/NoPrompt/venv
/opt/NoPrompt/venv/bin/pip install --no-cache-dir -r /opt/NoPrompt/requirements.txt
echo "alias noprompt=\"/opt/NoPrompt/venv/bin/python /opt/NoPrompt/noprompt.py\"" >/root/.bashrc.d/noprompt.rc

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

# snotra azure
git clone --depth 1 "https://gitlab.com/snotra.cloud/azure.git" /opt/snotra_azure
python3 -m venv /opt/snotra_azure/venv
/opt/snotra_azure/venv/bin/pip install --no-cache-dir -r /opt/snotra_azure/requirements.txt
echo "alias snotra_azure=\"/opt/snotra_azure/venv/bin/python /opt/snotra_azure/snotra.py\"" >/root/.bashrc.d/snotra_azure.rc

# azqr
latest_azqr=$(curl -sL https://api.github.com/repos/Azure/azqr/releases/latest | jq -r ".tag_name" | cut -c1-)
wget https://github.com/Azure/azqr/releases/download/"$latest_azqr"/azqr-linux-amd64.zip -O /opt/azqr.zip
unzip -uj -qq /opt/azqr.zip -d /opt
install -o root -g root -m 0755 /opt/azqr /usr/local/bin/azqr
rm /opt/azqr.zip
rm /opt/azqr
