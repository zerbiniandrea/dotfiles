-- Gate eslint LSP to projects that actually have an ESLint config.
-- See :help lsp-config-merge — after/lsp/ takes priority over lsp/.

return {
  root_markers = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".eslintrc.yaml",
    ".eslintrc",
  },
}
