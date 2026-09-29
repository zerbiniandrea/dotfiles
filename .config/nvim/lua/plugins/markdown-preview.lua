return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  ft = { 'markdown' },
  -- Pulls the prebuilt server binary from GitHub releases (no yarn needed).
  -- Calling mkdp#util#install() here does NOT work: the plugin is lazy-loaded,
  -- so its autoload/ dir is not on the runtimepath when the build hook fires.
  build = 'bash app/install.sh',
  init = function()
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_theme = 'dark'
    -- follow the cursor, but do not scroll the buffer from the browser
    vim.g.mkdp_preview_options = {
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      -- mermaid/katex ship with the bundled renderer
      maid = {},
      katex = {},
    }
  end,
  keys = {
    { '<leader>tp', '<cmd>MarkdownPreviewToggle<cr>', desc = '[T]oggle markdown [P]review', ft = 'markdown' },
  },
}
