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
      -- kanagawa stripes the entire gutter a lighter #282727 from one field,
      -- theme.ui.bg_gutter: LineNr/Sign/FoldColumn, CursorLineNr, AND every
      -- Diagnostic/Git sign bg. noice links its cmdline border/title/icon to
      -- DiagnosticSign*, so that stripe also leaks into the cmdline popup chrome.
      -- Null bg_gutter at the source → transparent gutter + clean cmdline border,
      -- like tokyonight/kanso. (foreground sign colors are unaffected.)
      colors = {
        theme = { all = { ui = { bg_gutter = 'none' } } },
      },
      -- kanagawa also paints floats a near-black #0d0c0c panel (dark box + seam
      -- behind rounded borders) and the completion menu its signature blue
      -- #223249. Match both to the editor bg so kanagawa reads as flat as the
      -- other themes. Partial bg-only overrides deep-merge into kanagawa's
      -- defaults, so fg colors (border lines, kind icons) are preserved; PmenuSel
      -- keeps its blue so the selected completion item still pops.
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = theme.ui.bg },
          FloatBorder = { bg = theme.ui.bg },
          FloatTitle = { bg = theme.ui.bg },
          FloatFooter = { bg = theme.ui.bg },
          StatusLine = { bg = 'none' },
          StatusLineNC = { bg = 'none' },
          Pmenu = { bg = theme.ui.bg },
          BlinkCmpMenuBorder = { bg = theme.ui.bg },
        }
      end,
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
