return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
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
  { -- Git wrapper for vim
    'tpope/vim-fugitive',
  },
  { -- Enhanced diff viewer
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = 'diff2_horizontal',
            winbar_info = true,
          },
          file_history = {
            layout = 'diff2_horizontal',
            winbar_info = true,
          },
        },
        file_panel = {
          listing_style = 'list',
        },
      }

      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = '[G]it [D]iff view' })
      vim.keymap.set('n', '<leader>gD', ':DiffviewClose<CR>', { desc = '[G]it [D]iff close' })
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory<CR>', { desc = '[G]it [H]istory' })
      vim.keymap.set('n', '<leader>gH', ':DiffviewFileHistory %<CR>', { desc = '[G]it [H]istory (current file)' })
    end,
  },
}
