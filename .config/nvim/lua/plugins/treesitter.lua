return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }

      require('nvim-treesitter').install {
        'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
        'query', 'vim', 'vimdoc', 'typescript', 'javascript', 'tsx', 'json', 'css',
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
      max_lines = 0,
      line_numbers = true,
      multiline_threshold = 20,
      mode = 'cursor',
    },
  },
}

