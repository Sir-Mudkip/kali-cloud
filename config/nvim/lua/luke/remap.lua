-- File explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted text up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")  -- Move selection down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")  -- Move selection up

-- Join lines while keeping cursor position
vim.keymap.set("n", "J", "mzJ`z")  -- Join line below without moving cursor

-- Keep cursor in the middle when scrolling/searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")  -- Scroll down, center cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz")  -- Scroll up, center cursor
vim.keymap.set("n", "n", "nzzzv")        -- Next search result, center
vim.keymap.set("n", "N", "Nzzzv")        -- Previous search result, center

-- Paste without overwriting paste buffer
vim.keymap.set("x", "<leader>p", [["_dP]])  -- Paste in visual mode without yanking deleted text

-- Disable Ex mode (Q key)
vim.keymap.set("n", "Q", "<nop>")

-- Maintain visual selection when indenting/dedenting
vim.keymap.set("x", "<", "<gv")  -- Dedent and keep selection
vim.keymap.set("x", ">", ">gv")  -- Indent and keep selection

-- Cycle between buffers
vim.keymap.set("n", "<leader>n", vim.cmd.bnext)  -- Next buffer
vim.keymap.set("n", "<leader>p", vim.cmd.bprev)  -- Previous buffer

-- Telescope fuzzy finder
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope recent files' })

