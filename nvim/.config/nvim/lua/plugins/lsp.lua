-- Language servers on top of the LazyVim extras in lazyvim.json.
-- Servers listed here are installed by Mason and started automatically,
-- unless they say mason = false.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ruby: use the ruby-lsp of each project's own Ruby (via mise; it's
        -- installed with every mise Ruby through ~/.default-gems), not Mason's.
        -- Neovim already starts it from the project folder, so mise picks
        -- the right Ruby.
        ruby_lsp = { mason = false },
        -- Ruby LSP runs RuboCop itself when the project has it, so the
        -- separate RuboCop server from the Ruby extra would duplicate warnings.
        rubocop = { enabled = false },

        herb_ls = {}, -- ERB (Herb)
        html = {},
        cssls = {},
        emmet_language_server = {},
        lemminx = {}, -- XML: completion, validation, formatting
      },
    },
  },
  {
    "stevearc/conform.nvim",
    -- Format through the language servers, so each project's own config applies:
    -- Ruby via Ruby LSP (the project's RuboCop), ERB via Herb (.herb.yml).
    -- A function, because these replace the Ruby extra's command-line
    -- formatters (rubocop, erb_format) instead of merging with them.
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.ruby = { lsp_format = "prefer", name = "ruby_lsp" }
      opts.formatters_by_ft.eruby = { lsp_format = "prefer", name = "herb_ls" }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss", "embedded_template" } },
  },
}
