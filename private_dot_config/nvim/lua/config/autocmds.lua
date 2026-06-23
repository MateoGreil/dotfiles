-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Drop timeoutlen while a :terminal buffer has focus so the <Esc><Esc>
-- mapping (in config/keymaps.lua) resolves quickly: a single ESC tap reaches
-- the inner process after ~200ms instead of the default 1000ms wait.
local term_timeout = vim.api.nvim_create_augroup("TermTimeout", { clear = true })
local saved_timeoutlen
vim.api.nvim_create_autocmd("TermEnter", {
  group = term_timeout,
  callback = function()
    saved_timeoutlen = saved_timeoutlen or vim.o.timeoutlen
    vim.o.timeoutlen = 200
  end,
})
vim.api.nvim_create_autocmd("TermLeave", {
  group = term_timeout,
  callback = function()
    if saved_timeoutlen then
      vim.o.timeoutlen = saved_timeoutlen
      saved_timeoutlen = nil
    end
  end,
})

local term_insert = vim.api.nvim_create_augroup("TermAutoInsert", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermOpen" }, {
  group = term_insert,
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.wo.wrap = true
      vim.cmd("startinsert")
    end
  end,
})
