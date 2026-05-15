-- Custom claudecode.nvim provider: open Claude in the CURRENT window
-- (replaces the displayed buffer) instead of a new float/split. The
-- env_table from the plugin is forwarded to termopen so the WebSocket
-- IDE integration (Send/Diff/Accept/Deny) keeps working.
local current_window_provider = {
  _bufnr = nil,
  _jobid = nil,
}

local function buf_valid()
  return current_window_provider._bufnr
    and vim.api.nvim_buf_is_valid(current_window_provider._bufnr)
end

local function find_term_win()
  if not buf_valid() then
    return nil
  end
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(w) == current_window_provider._bufnr then
      return w
    end
  end
  return nil
end

local function hide_in(win)
  local alt = vim.fn.bufnr("#")
  if alt > 0 and vim.api.nvim_buf_is_valid(alt) and alt ~= current_window_provider._bufnr then
    vim.api.nvim_win_set_buf(win, alt)
  else
    vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
  end
end

local function open_here(cmd_string, env_table, config, focus)
  if buf_valid() then
    vim.api.nvim_set_current_buf(current_window_provider._bufnr)
    if focus ~= false then
      vim.cmd("startinsert")
    end
    return
  end
  vim.cmd("enew")
  local jobid = vim.fn.termopen(cmd_string, {
    env = env_table,
    cwd = config and config.cwd or nil,
  })
  if not jobid or jobid <= 0 then
    vim.notify("claudecode: failed to start terminal", vim.log.levels.ERROR)
    return
  end
  current_window_provider._bufnr = vim.api.nvim_get_current_buf()
  current_window_provider._jobid = jobid
  vim.bo[current_window_provider._bufnr].bufhidden = "hide"
  pcall(vim.api.nvim_buf_set_name, current_window_provider._bufnr, "claude")
  if focus ~= false then
    vim.cmd("startinsert")
  end
end

function current_window_provider.setup(_) end

function current_window_provider.is_available()
  return true
end

function current_window_provider.open(cmd_string, env_table, config, focus)
  open_here(cmd_string, env_table, config, focus)
end

function current_window_provider.close()
  if buf_valid() then
    vim.api.nvim_buf_delete(current_window_provider._bufnr, { force = true })
  end
  current_window_provider._bufnr = nil
  current_window_provider._jobid = nil
end

function current_window_provider.simple_toggle(cmd_string, env_table, config)
  local w = find_term_win()
  if w then
    hide_in(w)
  else
    open_here(cmd_string, env_table, config, true)
  end
end

function current_window_provider.focus_toggle(cmd_string, env_table, config)
  local w = find_term_win()
  if w == vim.api.nvim_get_current_win() then
    hide_in(w)
  elseif w then
    vim.api.nvim_set_current_win(w)
    vim.cmd("startinsert")
  else
    open_here(cmd_string, env_table, config, true)
  end
end

current_window_provider.toggle = current_window_provider.simple_toggle

function current_window_provider.ensure_visible()
  if not buf_valid() then
    return
  end
  if find_term_win() then
    return
  end
  vim.api.nvim_set_current_buf(current_window_provider._bufnr)
end

function current_window_provider.get_active_bufnr()
  return buf_valid() and current_window_provider._bufnr or nil
end

function current_window_provider._get_terminal_for_test()
  return nil
end

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeOpen",
      "ClaudeCodeClose",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeSelectModel",
    },
    opts = {
      terminal = {
        provider = current_window_provider,
      },
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
