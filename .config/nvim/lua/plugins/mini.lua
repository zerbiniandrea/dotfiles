return {
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons() -- Make other plugins use mini.icons
    end,
  },
}