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
        -- hidden terminal buffer named "term0", available via :b term0
        local term_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_call(term_buf, function()
          vim.fn.jobstart(vim.o.shell, { term = true })
        end)
        vim.api.nvim_buf_set_name(term_buf, "term0")
        vim.cmd("terminal claude agents --cwd=.")
        pcall(vim.api.nvim_buf_set_name, vim.api.nvim_get_current_buf(), "claude")
        vim.cmd("startinsert")
      end)
    end
  end,
})

vim.cmd("cnoreabbrev vibe terminal vibe")
vim.cmd("cnoreabbrev tuicr terminal tuicr")

require("config.lazy")
