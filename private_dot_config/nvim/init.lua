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

-- :pi -> open a terminal running `pi`, with the buffer named "pi" (like claude
-- above). `:terminal pi` swallows the rest of the line, so the rename can't be
-- chained after it; do it as a user command. pcall guards against E95 if a "pi"
-- buffer already exists.
vim.api.nvim_create_user_command("Pi", function()
  vim.cmd("terminal pi")
  pcall(vim.api.nvim_buf_set_name, vim.api.nvim_get_current_buf(), "pi")
  vim.cmd("startinsert")
end, { desc = "Open a terminal running pi (buffer named 'pi')" })
-- Let `:pi` resolve to :Pi, but only when the whole cmdline is exactly "pi"
-- (so paths/args containing "pi" aren't rewritten).
vim.cmd([[cnoreabbrev <expr> pi getcmdtype() ==# ':' && getcmdline() ==# 'pi' ? 'Pi' : 'pi']])

require("config.lazy")
