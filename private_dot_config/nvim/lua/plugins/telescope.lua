return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- change a keymap
    { ":Rg", "<cmd>Telescope live_grep<cr>", desc = "Grep files" },
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Grep files" },
    { "<C-b>", "<cmd>Telescope buffers<cr>", desc = "Grep files" },
  },
}
