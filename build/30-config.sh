#!/usr/bin/env bash

set -eoux pipefail

# locales
sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=en_GB.UTF-8

# hide login banner
touch ~/.hushlogin

# ignore case on tab completion
echo "set completion-ignore-case On" >> /etc/inputrc

# neovim plugins
/root/.config/nvim/install-plugins.sh
