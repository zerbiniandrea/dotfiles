return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      preset = 'helix',
      delay = 300,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = {},
      },
      win = {
        border = 'rounded',
        title = true,
        title_pos = 'center',
        padding = { 1, 2 },
      },
      layout = {
        spacing = 3,
      },
      spec = {
        { '<leader>s', group = 'Search' },
        { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
        { '<leader>g', group = 'Git' },
        { '<leader>u', group = 'UI' },
      },
    },
  },
}