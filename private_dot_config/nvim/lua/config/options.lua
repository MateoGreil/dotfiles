-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set colorcolumn to 120
vim.opt.colorcolumn = "120"

-- Set the terminal window title to "<cwd dirname> - <current file>"
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')} - %t"
