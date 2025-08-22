return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  keys = {
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
  },
  opts = {
    jump = {
      nohlsearch = true,
    },
    modes = {
      char = {
        highlight = { backdrop = false },
      },
    },
  },
}

