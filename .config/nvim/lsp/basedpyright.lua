return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        diagnosticSeverityOverrides = {
          reportUnusedImport = 'none',
          reportUnusedVariable = 'none',
          reportUnusedFunction = 'none',
        },
      },
    },
  },
}
