-- Ctrl + h/j/k/l moves between Neovim splits and, at the edge, on into the
-- neighbouring tmux pane. Pairs with the Ctrl + h/j/k/l bindings in
-- ~/.config/tmux/overrides.conf. Replaces LazyVim's own Ctrl + h/j/k/l
-- (window moves inside Neovim only).
return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower window/pane" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper window/pane" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
  },
}
