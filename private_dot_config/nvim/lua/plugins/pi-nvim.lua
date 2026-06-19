return {
  -- Bridge to the pi coding agent: send files / selections / prompts from
  -- nvim into a running pi session (auto-discovers the socket under
  -- /tmp/pi-nvim-sockets, preferring a session matching the cwd). setup()
  -- also starts a 1s checktime poll so buffers reload when pi edits files.
  -- Pi side is registered in ~/.pi/agent/settings.json ("npm:pi-nvim").
  "carderne/pi-nvim",
  event = "VeryLazy",
  config = function()
    require("pi-nvim").setup()
    -- Default keymaps stay on: <leader>p sends to pi (normal + visual).
    -- Commands: :Pi :PiSend :PiSendFile :PiSendSelection :PiSendBuffer
    --           :PiPing :PiSessions
  end,
}
