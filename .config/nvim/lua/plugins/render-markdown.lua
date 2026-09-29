return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  ft = { 'markdown' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- render in every mode; anti_conceal un-hides the raw source on the cursor
    -- line only, so editing stays honest without losing the rendered view
    render_modes = { 'n', 'v', 'i', 'c', 'V', '\22' },
    anti_conceal = { enabled = true },
    -- no latex2text/tectonic installed; skip formula rendering instead of failing
    latex = { enabled = false },
    heading = { position = 'inline', width = 'block', left_pad = 0, right_pad = 2 },
    code = { width = 'block', right_pad = 2, language_pad = 1 },
    checkbox = { unchecked = { icon = '󰄱 ' }, checked = { icon = '󰱒 ' } },
  },
  keys = {
    { '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', desc = '[T]oggle [M]arkdown render', ft = 'markdown' },
  },
}
