-- bootstrap lazy.nvim, LazyVim and your plugins

-- On `nvim <dir>`, launch the AgentsBoard. Deferred to `VeryLazy` so LazyVim's
-- plugins (and the AgentsBoard command) are set up first.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local arg = vim.fn.argv(0)
    if arg == "" or vim.fn.isdirectory(arg) ~= 1 then
      return
    end
    vim.schedule(function()
      vim.cmd("AgentsBoard")
    end)
  end,
})

require("config.lazy")
