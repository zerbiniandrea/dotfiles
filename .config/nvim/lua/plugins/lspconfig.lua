return {
  {
    -- Configures Lua LSP for Neovim config, runtime and plugins
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      -- Extend LSP capabilities with blink.cmp
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- Keymaps on LSP attach
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Navigation
          map('grd', function() require('snacks.picker').lsp_definitions() end, 'Goto Definition')
          map('grD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('grr', function() require('snacks.picker').lsp_references() end, 'Goto References')
          map('gri', function() require('snacks.picker').lsp_implementations() end, 'Goto Implementation')
          map('grt', function() require('snacks.picker').lsp_type_definitions() end, 'Goto Type Definition')
          map('gO', function() require('snacks.picker').lsp_symbols() end, 'Document Symbols')
          map('gW', function() require('snacks.picker').lsp_workspace_symbols() end, 'Workspace Symbols')

          -- Actions
          map('grn', vim.lsp.buf.rename, 'Rename')
          map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>oi', function()
            vim.lsp.buf.code_action {
              context = { only = { 'source.organizeImports' }, diagnostics = {} },
              apply = true,
            }
          end, 'Organize Imports')

          -- Document highlight on cursor hold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config {
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
      }

      -- Mason: ensure tools are installed
      require('mason-tool-installer').setup {
        ensure_installed = {
          -- LSPs
          'lua-language-server',
          'vtsls',
          'eslint-lsp',
          'bash-language-server',
          'dockerfile-language-server',
          'yaml-language-server',
          'taplo', -- TOML
          'css-lsp',
          'html-lsp',
          'json-lsp',
          'hyprls',
          -- Formatters
          'stylua',
          'prettier',
          'shfmt',
          -- Linters
          'shellcheck',
          'hadolint',
          'actionlint',
        },
      }

      -- Mason-lspconfig: auto-enable installed servers
      require('mason-lspconfig').setup {
        automatic_enable = {
          exclude = { 'ts_ls' }, -- Use vtsls instead
        },
      }
    end,
  },
}
