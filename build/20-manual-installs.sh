#!/usr/bin/env bash

set -eoux pipefail

# Testssl
git clone --depth 1 https://github.com/testssl/testssl.sh.git --branch 3.3dev /opt/testssl
chmod +x /opt/testssl/testssl.sh
echo "alias testssl=\"/opt/testssl/testssl.sh\"" > /root/.bashrc.d/testssl.rc

# impacket latest (pipx exposes the example scripts on PATH in ~/.local/bin, keeping the .py suffix)
pipx install git+https://github.com/fortra/impacket

# Seclists
git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists
tar -xzvf /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C /usr/share/seclists/Passwords/Leaked-Databases/

# Linkedin Dumper
git clone https://github.com/l4rm4nd/LinkedInDumper /opt/linkedin-dumper
python3 -m venv /opt/linkedin-dumper/venv
/opt/linkedin-dumper/venv/bin/pip install --no-cache-dir -r /opt/linkedin-dumper/requirements.txt
echo "alias linkedin-dumper=\"/opt/linkedin-dumper/venv/bin/python /opt/linkedin-dumper/linkedindumper.py\"" > /root/.bashrc.d/linkedin-dumper.rc

# haiti hash
gem install haiti-hash

# AAD Internals
pwsh -c "Install-Module -Name AADInternals -Force"
pwsh -c "Install-Module -Name AADInternals-Endpoints -Force"
