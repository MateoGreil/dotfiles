local function load_theme()
  local sentinel = vim.fn.expand("~/.config/theme-mode")
  local f = io.open(sentinel, "r")
  if not f then
    return
  end
  local mode = (f:read("*l") or ""):gsub("%s+", "")
  f:close()
  if mode == "light" or mode == "dark" then
    vim.o.background = mode
  end
end

return {
  {
    "ellisonleao/gruvbox.nvim",
    init = function()
      load_theme()
      vim.api.nvim_create_user_command("ThemeReload", function()
        load_theme()
        vim.cmd.colorscheme("gruvbox")
      end, { desc = "Re-read ~/.config/theme-mode and reapply gruvbox" })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
