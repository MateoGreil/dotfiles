-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- Resize window using <ctrl> hjkl
map("n", "<C-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-l>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-h>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
-- Copy path file to clipboard
map("n", ",cs", ':let @+=expand("%")<CR>', { desc = "Copy file path to clipboard" })
map("n", ",cl", ':let @+=expand("%:p")<CR>', { desc = "Copy absolute file path to clipboard" })
-- Exit terminal mode with a single ESC press
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Go to normal mode from terminal" })
-- Open current file in a new tab
map("n", "<C-w>f", ":tabe %<CR>", { noremap = true, silent = true, desc = "Open current file in a new tab" })

-- Telescope
local telescope = require("telescope.builtin")
map("n", ":Rg", telescope.live_grep, { desc = "Telescope live grep" })
map("n", "<C-p>", telescope.find_files, { desc = "Telescope find files" })
map("n", "<C-b>", telescope.buffers, { desc = "Telescope buffers" })
