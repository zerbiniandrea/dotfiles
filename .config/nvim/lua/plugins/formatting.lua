local function web_formatter(bufnr)
  if vim.fs.root(bufnr, { '.oxfmtrc', '.oxfmtrc.json', 'oxfmt.config.js' }) then
    return { 'oxfmt' }
  end
  return { 'prettier' }
end

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Check if file exists before formatting
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname ~= '' and vim.fn.filereadable(bufname) == 0 then
          -- File doesn't exist, don't format (prevents recreating deleted files)
          return nil
        end

        -- Format all filetypes except those explicitly disabled
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end

        return {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = web_formatter,
        javascriptreact = web_formatter,
        typescript = web_formatter,
        typescriptreact = web_formatter,
        json = web_formatter,
        yaml = web_formatter,
        css = web_formatter,
        html = web_formatter,
        markdown = { 'prettier' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        toml = { 'taplo' },
        python = { 'ruff_organize_imports', 'ruff_format' },
      },
    },
  },
}