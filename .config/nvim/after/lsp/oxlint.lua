-- Override nvim-lspconfig's oxlint config.
-- See :help lsp-config-merge — after/lsp/ takes priority over lsp/.

return {
  settings = {
    typeAware = true,
  },
  root_markers = {
    ".oxlintrc.json",
    ".oxlintrc.jsonc",
    "oxlint.config.ts",
    "oxlint.config.js",
    "oxlint.config.mjs",
  },
  -- Prefer the project-pinned oxlint binary (resolved via upward walk for
  -- pnpm/yarn-workspace monorepos that hoist binaries to the workspace root).
  -- Falls back to PATH (typically Mason's install) if no local binary found.
  cmd = function(dispatchers, config)
    local cmd = 'oxlint'
    if (config or {}).root_dir then
      local found = vim.fs.find('node_modules/.bin/oxlint', {
        upward = true,
        path = config.root_dir,
        type = 'file',
      })[1]
      if found and vim.fn.executable(found) == 1 then
        cmd = found
      end
    end
    return vim.lsp.rpc.start({ cmd, '--lsp' }, dispatchers)
  end,
}
