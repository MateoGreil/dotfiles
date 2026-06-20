return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
  },
  -- Merge into LazyVim's telescope opts (don't override its `config`, so
  -- fzf-native + the default <leader>f / <leader>s keymaps stay intact).
  opts = function(_, opts)
    local lga_actions = require("telescope-live-grep-args.actions")
    opts.extensions = opts.extensions or {}
    opts.extensions.live_grep_args = {
      auto_quoting = true, -- auto-wrap the first word in quotes
      mappings = {
        i = {
          ["<C-k>"] = lga_actions.quote_prompt(), -- foo -> "foo"
          ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }), -- "foo" --iglob
          ["<C-space>"] = lga_actions.to_fuzzy_refine, -- switch to fuzzy filtering
        },
      },
    }
  end,
}
