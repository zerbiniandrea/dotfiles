return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = function()
    -- Flatten the auto theme into a transparent bar: null every section
    -- background so the statusline blends into the editor instead of showing
    -- colored blocks. The mode block (section a) carries a dark fg meant to sit
    -- on a bright background, so recolor its fg to that accent — leaving
    -- colored, readable mode text on the transparent bar across every theme.
    local theme = require 'lualine.themes.auto'
    for _, mode in pairs(theme) do
      for name, section in pairs(mode) do
        if name == 'a' and section.bg then
          section.fg = section.bg
        end
        section.bg = 'NONE'
      end
    end

    return {
      options = {
        theme = theme,
        globalstatus = true,
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
          statusline = { 'snacks_dashboard', 'snacks_picker', 'snacks_explorer' },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        -- filename lives in the floating incline label now (see incline.lua)
        lualine_c = {},
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      extensions = { 'lazy' },
    }
  end,
}
