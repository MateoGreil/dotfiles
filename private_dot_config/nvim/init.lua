-- bootstrap lazy.nvim, LazyVim and your plugins

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_get_name(buf) == "" and vim.bo[buf].buftype == "" then
            vim.api.nvim_set_current_win(win)
            break
          end
        end
        vim.cmd("terminal claude")
        vim.cmd("file claude")
        vim.cmd("belowright 15split | terminal")
        vim.cmd("wincmd k")
      end)
    end
  end,
})

require("config.lazy")
