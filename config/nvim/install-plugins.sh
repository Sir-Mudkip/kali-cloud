#!/usr/bin/bash

set -eoux pipefail

mkdir -p /root/.local/share/nvim/site/pack/plugins/start && \
cd /root/.local/share/nvim/site/pack/plugins/start && \
git clone --depth 1 https://github.com/nvim-lua/plenary.nvim && \
git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim && \
git clone --depth 1 https://github.com/uhs-robert/oasis.nvim && \
git clone --depth 1 https://github.com/nvim-tree/nvim-web-devicons && \
git clone --depth 1 https://github.com/nvim-neo-tree/neo-tree.nvim && \
git clone --depth 1 https://github.com/MunifTanjim/nui.nvim && \
git clone --depth 1 https://github.com/nvimdev/dashboard-nvim
