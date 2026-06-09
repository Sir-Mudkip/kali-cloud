#!/usr/bin/env bash

set -eoux pipefail

# wordlists
git clone https://github.com/insidetrust/statistically-likely-usernames /usr/share/statistically-likely-usernames

# prep wordlist files for msf usage
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/mssql-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/mssql-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/mysql-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/mysql-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/ssh-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/ssh-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/ftp-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/ftp-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/postgres-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/postgres-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/vnc-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/vnc-betterdefaultpasslist_spaces.txt
sed -e "s/:/ /" /usr/share/seclists/Passwords/Default-Credentials/tomcat-betterdefaultpasslist.txt > /usr/share/seclists/Passwords/Default-Credentials/tomcat-betterdefaultpasslist_spaces.txt
