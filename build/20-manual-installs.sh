#!/usr/bin/env bash

set -eoux pipefail

# Testssl
git clone --depth 1 https://github.com/testssl/testssl.sh.git --branch 3.3dev /opt/testssl
chmod +x /opt/testssl/testssl.sh
echo "alias testssl=\"/opt/testssl/testssl.sh\"" > /root/.bashrc.d/testssl.rc

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

# impacket latest (pipx exposes the example scripts on PATH in ~/.local/bin, keeping the .py suffix)
pipx install git+https://github.com/fortra/impacket

# targetted kerberoast
git clone --depth 1 https://github.com/ShutdownRepo/targetedKerberoast /opt/targetedKerberoast
python3 -m venv /opt/targetedKerberoast/venv
/opt/targetedKerberoast/venv/bin/pip install --no-cache-dir -r /opt/targetedKerberoast/requirements.txt
echo "alias targetedKerberoast=\"/opt/targetedKerberoast/venv/bin/python /opt/targetedKerberoast/targetedKerberoast.py\"" > /root/.bashrc.d/targetedKerberoast.rc

# pywhisker
pipx install git+https://github.com/ShutdownRepo/pywhisker

# git-dumper
pipx install git+https://github.com/arthaud/git-dumper

# bloodyAD
pipx install git+https://github.com/CravateRouge/bloodyAD

# cve-2019-1040-scanner
git clone --depth 1 https://github.com/fox-it/cve-2019-1040-scanner /opt/cve-2019-1040-scanner
echo "alias cve-2019-1040-scanner=\"python3 /opt/cve-2019-1040-scanner/scan.py\"" > /root/.bashrc.d/cve-2019-1040-scanner.rc

# adidnsdump
pipx install git+https://github.com/dirkjanm/adidnsdump

# privexchange
git clone --depth 1 https://github.com/dirkjanm/privexchange /opt/privexchange
python3 -m venv /opt/privexchange/venv
/opt/privexchange/venv/bin/pip install --no-cache-dir -r /opt/privexchange/requirements.txt
echo "alias privexchange=\"/opt/privexchange/venv/bin/python /opt/privexchange/privexchange.py\"" > /root/.bashrc.d/privexchange.rc

# pcredz
git clone --depth 1 https://github.com/lgandx/PCredz /opt/PCredz
DEBIAN_FRONTEND=noninteractive apt update && apt -y install libpcap-dev
python3 -m venv /opt/PCredz/venv
/opt/PCredz/venv/bin/pip install --no-cache-dir Cython
/opt/PCredz/venv/bin/pip install --no-cache-dir python-libpcap
echo "alias Pcredz=\"/opt/PCredz/venv/bin/python /opt/PCredz/Pcredz\"" > /root/.bashrc.d/Pcredz.rc

# krbrelayx
git clone --depth 1 https://github.com/dirkjanm/krbrelayx /opt/krbrelayx
python3 -m venv /opt/krbrelayx/venv
/opt/krbrelayx/venv/bin/pip install --no-cache-dir impacket ldap3 dnspython
echo "alias krbrelayx=\"/opt/krbrelayx/venv/bin/python /opt/krbrelayx/krbrelayx.py\"" > /root/.bashrc.d/krbrelayx.rc

# passthecert
git clone --depth 1 https://github.com/AlmondOffSec/PassTheCert /opt/PassTheCert
echo "alias passthecert=\"python3 /opt/PassTheCert/Python/passthecert.py\"" > /root/.bashrc.d/PassTheCert.rc

# gittools
git clone --depth 1 https://github.com/internetwache/GitTools /opt/GitTools
install -o root -g root -m 0755 /opt/GitTools/Dumper/gitdumper.sh /usr/local/bin/gitdumper
install -o root -g root -m 0755 /opt/GitTools/Extractor/extractor.sh /usr/local/bin/gitextractor
echo "alias gitfinder=\"python3 /opt/GitTools/Finder/gitfinder.py\"" > /root/.bashrc.d/gitfinder.rc

# pkinittools
git clone --depth 1 https://github.com/dirkjanm/PKINITtools /opt/PKINITtools
python3 -m venv /opt/PKINITtools/venv
/opt/PKINITtools/venv/bin/pip install --no-cache-dir -r /opt/PKINITtools/requirements.txt
echo "alias gettgtpkinit=\"python3 /opt/PKINITtools/gettgtpkinit.py\"" > /root/.bashrc.d/gettgtpkinit.rc
echo "alias getnthash=\"python3 /opt/PKINITtools/getnthash.py\"" > /root/.bashrc.d/getnthash.rc
echo "alias gets4uticket=\"python3 /opt/PKINITtools/gets4uticket.py\"" > /root/.bashrc.d/gets4uticket.rc

# sapito
git clone --depth 1 https://github.com/eldraco/Sapito /opt/Sapito
python3 -m venv /opt/Sapito/venv
/opt/Sapito/venv/bin/pip install --no-cache-dir -r /opt/Sapito/requirements.txt
echo "alias sapito=\"python3 /opt/Sapito/sapito.py\"" > /root/.bashrc.d/sapito.rc

# jexboss
git clone --depth 1 https://github.com/joaomatosf/jexboss /opt/jexboss
python3 -m venv /opt/jexboss/venv
/opt/jexboss/venv/bin/pip install --no-cache-dir -r /opt/jexboss/requires.txt
echo "alias jexboss=\"python3 /opt/jexboss/jexboss.py\"" > /root/.bashrc.d/jexboss.rc

# rsh
git clone --depth 1 https://github.com/mzfr/rsh /opt/rsh
python3 -m venv /opt/rsh/venv
/opt/rsh/venv/bin/pip install --no-cache-dir -r /opt/rsh/requirements.txt
echo "alias rsh=\"python3 /opt/rsh/rsh\"" > /root/.bashrc.d/rsh.rc

# jwt_tool
git clone --depth 1 https://github.com/ticarpi/jwt_tool /opt/jwt_tool
python3 -m venv /opt/jwt_tool/venv
/opt/jwt_tool/venv/bin/pip install --no-cache-dir -r /opt/jwt_tool/requirements.txt
echo "alias jwt_tool=\"/opt/jwt_tool/venv/bin/python3 /opt/jwt_tool/jwt_tool.py\"" > /root/.bashrc.d/jwt_tool.rc

# Linkedin Dumper
git clone https://github.com/l4rm4nd/LinkedInDumper /opt/linkedin-dumper
python3 -m venv /opt/linkedin-dumper/venv
/opt/linkedin-dumper/venv/bin/pip install --no-cache-dir -r /opt/linkedin-dumper/requirements.txt
echo "alias linkedin-dumper=\"/opt/linkedin-dumper/venv/bin/python /opt/linkedin-dumper/linkedindumper.py\"" > /root/.bashrc.d/linkedin-dumper.rc

# sharpcollection
git clone --depth 1 https://github.com/Flangvik/SharpCollection /opt/SharpCollection

# sharefiltrator
git clone --depth 1 "https://github.com/Friends-Security/sharefiltrator" /opt/sharefiltrator
python3 -m venv /opt/sharefiltrator/venv
/opt/sharefiltrator/venv/bin/pip install --no-cache-dir -r /opt/sharefiltrator/requirements.txt
echo "alias sharefiltrator=\"/opt/sharefiltrator/venv/bin/python /opt/sharefiltrator/sharefiltrator.py\"" > /root/.bashrc.d/sharefiltrator.rc

# kerbrute
wget -q https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O /opt/kerbrute
install -o root -g root -m 0755 /opt/kerbrute /usr/local/bin/kerbrute
rm /opt/kerbrute

wget -q https://github.com/hdm/nextnet/releases/download/v0.0.2/nextnet_0.0.2_linux_amd64.tar.gz -O /opt/nextnet_0.0.2_linux_amd64.tar.gz

wget -q https://github.com/lima-vm/sshocker/releases/download/v0.3.9/sshocker-Linux-x86_64 -O /opt/sshocker
install -o root -g root -m 0755 /opt/sshocker /usr/local/bin/sshocker
rm /opt/sshocker

wget -q https://github.com/antonioCoco/RunasCs/releases/download/v1.5/RunasCs.zip -O /opt/RunasCs.zip

# haiti hash
gem install haiti-hash

# ligolo agent binaries
wget -q https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_linux_amd64.tar.gz -O /opt/ligolo-ng_agent_0.8.2_linux_amd64.tar.gz
wget -q https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_windows_amd64.zip -O /opt/ligolo-ng_agent_0.8.2_windows_amd64.zip

# AAD Internals
pwsh -c "Install-Module -Name AADInternals -Force"
pwsh -c "Install-Module -Name AADInternals-Endpoints -Force"
