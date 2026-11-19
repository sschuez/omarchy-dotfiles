-- Ctrl + h/j/k/l moves between Neovim splits and, at the edge, on into the
-- neighbouring tmux or Herdr pane. Pairs with the Ctrl + h/j/k/l bindings in
-- ~/.config/tmux/overrides.conf and ~/.config/herdr/config.toml (through
-- herdr-navigate). Replaces LazyVim's own Ctrl + h/j/k/l (window moves inside
-- Neovim only).

-- In tmux, vim-tmux-navigator does it all. In Herdr, move between splits and,
-- when there's no split that way, ask Herdr to focus the next pane.
local function navigate(direction, wincmd)
  return function()
    if vim.env.TMUX then
      return vim.cmd("TmuxNavigate" .. direction)
    end

    local before = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(wincmd)
    if vim.api.nvim_get_current_win() == before and vim.env.HERDR_PANE_ID then
      local herdr = vim.env.HERDR_BIN_PATH or "herdr"
      vim.system({ herdr, "pane", "focus", "--pane", vim.env.HERDR_PANE_ID, "--direction", direction:lower() })
    end
  end
end

return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  -- Otherwise the plugin maps Ctrl + h/j/k/l itself when it loads, over the
  -- keys below, and its own maps only know tmux.
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<C-h>", navigate("Left", "h"), desc = "Go to left window/pane" },
    { "<C-j>", navigate("Down", "j"), desc = "Go to lower window/pane" },
    { "<C-k>", navigate("Up", "k"), desc = "Go to upper window/pane" },
    { "<C-l>", navigate("Right", "l"), desc = "Go to right window/pane" },
  },
}
