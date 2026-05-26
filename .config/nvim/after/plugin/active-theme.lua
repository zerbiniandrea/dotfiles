-- Applies the active colorscheme on startup based on ~/.cache/nvim-theme.
-- The file holds a single line: the colorscheme name (e.g. "oxocarbon").
-- Theme-switcher.sh writes this file when you swap themes; new nvim sessions
-- read it here. Running nvim sessions keep their current colorscheme until restart.

local function read_theme()
  local path = vim.fn.expand('~/.cache/nvim-theme')
  local f = io.open(path, 'r')
  if not f then return nil end
  local name = f:read('*l')
  f:close()
  if not name then return nil end
  return (name:gsub('^%s*(.-)%s*$', '%1'))
end

local cs = read_theme() or 'tokyonight-night'
local ok = pcall(vim.cmd.colorscheme, cs)
if not ok then
  pcall(vim.cmd.colorscheme, 'tokyonight-night')
end

-- ── Snacks ↔ theme bridge ───────────────────────────────────────────────────
-- kanagawa.nvim has no built-in snacks integration (kanagawa #266 open feature
-- request). And snacks's picker init runs *after* colorscheme setup, so doing
-- the overrides inside kanagawa's setup{overrides=...} loses (snacks #1688).
-- Re-applying on ColorScheme + LazyDone catches both cases.

local function apply_snacks_bridge()
  local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

  -- Window surfaces — link to Normal so they always match the editor bg
  -- regardless of which colorscheme is active.
  for _, g in ipairs({
    'SnacksPicker', 'SnacksPickerBox', 'SnacksPickerList',
    'SnacksPickerInput', 'SnacksPickerPreview', 'SnacksPickerPrompt',
    'SnacksNormal', 'SnacksNormalNC', 'SnacksDashboardNormal',
    'SnacksPickerInputCursorLine', 'SnacksPickerPreviewCursorLine',
  }) do
    hl(g, { link = 'Normal' })
  end

  -- Borders — link to FloatBorder
  for _, g in ipairs({
    'SnacksPickerBorder', 'SnacksPickerListBorder',
    'SnacksPickerInputBorder', 'SnacksPickerPreviewBorder',
  }) do
    hl(g, { link = 'FloatBorder' })
  end

  -- Titles / footers — link to FloatTitle
  for _, g in ipairs({
    'SnacksPickerTitle', 'SnacksPickerListTitle',
    'SnacksPickerInputTitle', 'SnacksPickerInputFooter',
    'SnacksPickerPromptTitle', 'SnacksPickerPreviewTitle',
  }) do
    hl(g, { link = 'FloatTitle' })
  end

  -- Tree row scaffolding — defaults to LineNr, which has a gutter bg in many
  -- themes. Link to Comment instead so the connector chars are muted-fg with
  -- transparent bg (= editor bg).
  hl('SnacksPickerTree', { link = 'Comment' })

  -- Keep the selected list row visible — link to Visual (theme-aware selection).
  hl('SnacksPickerListCursorLine', { link = 'Visual' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  group = vim.api.nvim_create_augroup('snacks_theme_bridge', { clear = true }),
  callback = function()
    -- Keep TreesitterContext transparent across all colorschemes
    vim.cmd('hi TreesitterContext none')
    apply_snacks_bridge()
  end,
})

-- Re-apply once after Lazy finishes loading plugins — snacks's picker init
-- happens during VimEnter; if it runs after the ColorScheme autocmd above,
-- our overrides get clobbered without this.
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  callback = apply_snacks_bridge,
})

-- And immediately, in case snacks already loaded by the time we get here.
vim.cmd('hi TreesitterContext none')
apply_snacks_bridge()
