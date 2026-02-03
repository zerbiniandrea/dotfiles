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
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      -- Workaround for noice.nvim E445 error on close
      local function diffview_safe_close()
        local hidden = vim.opt.hidden:get()
        vim.opt.hidden = true
        vim.cmd('DiffviewClose')
        vim.opt.hidden = hidden
      end

      require('diffview').setup {
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = 'diff2_horizontal',
            winbar_info = true,
            disable_diagnostics = true,
          },
          merge_tool = {
            layout = 'diff3_horizontal',
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = 'diff2_horizontal',
            winbar_info = true,
            disable_diagnostics = true,
          },
        },
        file_panel = {
          listing_style = 'tree',
          tree_options = {
            flatten_dirs = true,
            folder_statuses = 'only_folded',
          },
          win_config = {
            position = 'left',
            width = 40,
          },
          indent = 1,
        },
        file_history_panel = {
          win_config = {
            position = 'bottom',
            height = 16,
          },
        },
        signs = {
          fold_closed = '',
          fold_open = '',
          done = '✓',
        },
        icons = {
          folder_closed = '',
          folder_open = '',
        },
        keymaps = {
          view = {
            { 'n', 'q', diffview_safe_close, { desc = 'Close diffview' } },
          },
          file_panel = {
            { 'n', 'q', diffview_safe_close, { desc = 'Close diffview' } },
          },
          file_history_panel = {
            { 'n', 'q', diffview_safe_close, { desc = 'Close diffview' } },
          },
        },
      }

      vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff view' })
      vim.keymap.set('n', '<leader>gD', diffview_safe_close, { desc = '[G]it [D]iff close' })
      vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<CR>', { desc = '[G]it [H]istory' })
      vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it [H]istory (current file)' })
    end,
  },
}

