return {
  {
    dir = vim.fn.expand("~/agent-fleet.nvim"),
    name = "agent-fleet.nvim",
    cmd = { "Agent", "Agents", "AgentsBoard", "AgentResume", "AgentDone", "AgentArchive", "AgentRename" },
    keys = {
      { "<leader>aa", "<cmd>Agent<cr>", desc = "Agent Fleet: launch agent" },
      { "<leader>al", "<cmd>Agents<cr>", desc = "Agent Fleet: list & switch" },
      { "<leader>ab", "<cmd>AgentsBoard<cr>", desc = "Agent Fleet: board" },
      { "<leader>ad", "<cmd>AgentDone<cr>", desc = "Agent Fleet: done" },
      { "<leader>ax", "<cmd>AgentArchive<cr>", desc = "Agent Fleet: archive" },
    },
    config = function()
      require("agent-fleet").setup({})
    end,
  },
}
