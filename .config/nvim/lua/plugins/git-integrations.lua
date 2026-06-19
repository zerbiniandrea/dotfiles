return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true,
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = '[G]it [P]review hunk' })
      vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = '[G]it [S]tage hunk' })
      vim.keymap.set('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = '[G]it [U]nstage hunk' })
      vim.keymap.set('v', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = '[G]it [S]tage hunk' })
    end,
  },
  {
    'tpope/vim-fugitive',
  },
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {
      diff = {
        layout = 'side-by-side',
        compact_context_lines = 3,
        compact_sync_folds = true,
      },
      explorer = {
        position = 'left',
        width = 40,
        view_mode = 'tree',
        flatten_dirs = true,
      },
      keymaps = {
        view = {
          next_file = '<Tab>',
          prev_file = '<S-Tab>',
        },
      },
    },
    keys = {
      { '<leader>gd', '<cmd>CodeDiff<CR>', desc = '[G]it [D]iff view' },
      { '<leader>gh', '<cmd>CodeDiff history<CR>', desc = '[G]it [H]istory' },
      { '<leader>gH', '<cmd>CodeDiff history HEAD %<CR>', desc = '[G]it [H]istory (current file)' },
    },
  },
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    opts = {},
    keys = {
      {
        '<leader>gx',
        '<cmd>GitConflictListQf<cr><cmd>lua Snacks.picker.qflist()<cr>',
        desc = '[G]it Conflicts',
      },
    },
  },
}

