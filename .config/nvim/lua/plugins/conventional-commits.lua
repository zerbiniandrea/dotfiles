return {
  'zerbiniandrea/conventional-commits.nvim',
  dev = true, -- Use local version when available
  cmd = 'ConventionalCommit',
  config = function()
    require('conventional-commits').setup({})
  end,
  keys = {
    { '<leader>gc', '<cmd>ConventionalCommit<cr>', desc = 'Conventional Commit' },
  },
}
