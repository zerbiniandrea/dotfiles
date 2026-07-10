return {
  init_options = {
    -- golangci-lint v2 changed the output flags; the langserver's default
    -- command still uses v1 syntax, so override it here.
    command = { 'golangci-lint', 'run', '--output.json.path', 'stdout' },
  },
}
