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
