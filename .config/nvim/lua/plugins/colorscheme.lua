-- All colorscheme plugins. Active colorscheme is applied by
-- ~/.config/nvim/after/plugin/active-theme.lua based on ~/.cache/nvim-theme.
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      styles = { comments = { italic = false } },
    },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = { flavour = 'mocha' },
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      theme = 'dragon',
      background = { dark = 'dragon', light = 'lotus' },
      -- Snacks-specific overrides live in after/plugin/active-theme.lua so
      -- they apply on LazyDone / ColorScheme (snacks's picker init can
      -- override anything set earlier — see snacks #1688, kanagawa #266).
    },
  },
  {
    'nyoom-engineering/oxocarbon.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'Mofiqul/adwaita.nvim',
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.adwaita_darker = false
      vim.g.adwaita_disable_cursorline = false
      vim.g.adwaita_transparent = false
    end,
  },
  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
  },
}
