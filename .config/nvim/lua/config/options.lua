vim.opt.tabstop = 4 -- Width of tab character
vim.opt.shiftwidth = 4 -- Width of indentation
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true

-- Disable annoying change of working directory based on LSP
vim.g.root_spec = { "cwd" }
