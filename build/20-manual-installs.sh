#!/usr/bin/env bash

set -eoux pipefail

# Testssl
git clone --depth 1 https://github.com/testssl/testssl.sh.git --branch 3.3dev /opt/testssl
chmod +x /opt/testssl/testssl.sh
echo "alias testssl=\"/opt/testssl/testssl.sh\"" > /root/.bashrc.d/testssl.rc

<<<<<<< HEAD
# bloodhound cli
wget "https://github.com/SpecterOps/bloodhound-cli/releases/download/v0.2.1/bloodhound-cli-linux-amd64.tar.gz" -O "/opt/bloodhound-cli-linux-amd64.tar.gz"
tar -xzf "/opt/bloodhound-cli-linux-amd64.tar.gz" -C /opt/
rm "/opt/bloodhound-cli-linux-amd64.tar.gz"

# pip2
wget -q https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2 get-pip.py
rm get-pip.py

# john the ripper, brutespray, gowitness, wpprobe, gobuster, nuclei: compiled in the builder stage (see build/00-go-installs.sh)

# seth
git clone --depth 1 https://github.com/SySS-Research/Seth /opt/Seth

# sccmhunter
git clone --depth 1 https://github.com/garrettfoster13/sccmhunter /opt/sccmhunter
python3 -m venv /opt/sccmhunter/venv
/opt/sccmhunter/venv/bin/pip install --no-cache-dir -r /opt/sccmhunter/requirements.txt
echo "alias sccmhunter=\"/opt/sccmhunter/venv/bin/python /opt/sccmhunter/sccmhunter.py\"" > /root/.bashrc.d/sccmhunter.rc

# powerhub
pipx install powerhub

# eavesarp
git clone --depth 1 https://github.com/ImpostorKeanu/eavesarp /opt/eavesarp
python3 -m venv /opt/eavesarp/venv
/opt/eavesarp/venv/bin/pip install --no-cache-dir -r /opt/eavesarp/requirements.txt
echo "alias eavesarp=\"/opt/eavesarp/venv/bin/python /opt/eavesarp/eavesarp.py\"" > /root/.bashrc.d/eavesarp.rc

# dnscan
git clone --depth 1 https://github.com/rbsec/dnscan /opt/dnscan
python3 -m venv /opt/dnscan/venv
/opt/dnscan/venv/bin/pip install --no-cache-dir -r /opt/dnscan/requirements.txt
echo "alias dnsscan=\"/opt/dnscan/venv/bin/python /opt/dnscan/dnscan.py\"" > /root/.bashrc.d/dnsscan.rc

# pre2k
pipx install git+https://github.com/garrettfoster13/pre2k

||||||| parent of d446db1 (new build, stripped everything down to more minimal tools)
# bloodhound cli
wget "https://github.com/SpecterOps/bloodhound-cli/releases/download/v0.2.1/bloodhound-cli-linux-amd64.tar.gz" -O "/opt/bloodhound-cli-linux-amd64.tar.gz"
tar -xzf "/opt/bloodhound-cli-linux-amd64.tar.gz" -C /opt/
rm "/opt/bloodhound-cli-linux-amd64.tar.gz"

# pip2
wget -q https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2 get-pip.py
rm get-pip.py

# john the ripper, brutespray, gowitness, wpprobe, gobuster, nuclei: compiled in the builder stage (see build/00-go-installs.sh)

# seth
git clone --depth 1 https://github.com/SySS-Research/Seth /opt/Seth

# sccmhunter
git clone --depth 1 https://github.com/garrettfoster13/sccmhunter /opt/sccmhunter
python3 -m venv /opt/sccmhunter/venv
/opt/sccmhunter/venv/bin/pip install --no-cache-dir -r /opt/sccmhunter/requirements.txt
echo "alias sccmhunter=\"/opt/sccmhunter/venv/bin/python /opt/sccmhunter/sccmhunter.py\"" > /root/.bashrc.d/sccmhunter.rc

# powerhub
pipx install powerhub

# eavesarp
git clone --depth 1 https://github.com/ImpostorKeanu/eavesarp /opt/eavesarp
python3 -m venv /opt/eavesarp/venv
/opt/eavesarp/venv/bin/pip install --no-cache-dir -r /opt/eavesarp/requirements.txt
echo "alias eavesarp=\"/opt/eavesarp/venv/bin/python /opt/eavesarp/eavesarp.py\"" > /root/.bashrc.d/eavesarp.rc

# netexec
pipx ensurepath && pipx install git+https://github.com/Pennyw0rth/NetExec

# dnscan
git clone --depth 1 https://github.com/rbsec/dnscan /opt/dnscan
python3 -m venv /opt/dnscan/venv
/opt/dnscan/venv/bin/pip install --no-cache-dir -r /opt/dnscan/requirements.txt
echo "alias dnsscan=\"/opt/dnscan/venv/bin/python /opt/dnscan/dnscan.py\"" > /root/.bashrc.d/dnsscan.rc

# pre2k
pipx install git+https://github.com/garrettfoster13/pre2k

=======
>>>>>>> d446db1 (new build, stripped everything down to more minimal tools)
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
