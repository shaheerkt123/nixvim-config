-- Exit if the language server isn't available
if vim.fn.executable('nil') ~= 1 then
  return
end

local root_files = {
  'flake.nix',
  'default.nix',
  'shell.nix',
  '.git',
}

local root_file = vim.fs.find(root_files, { upward = true })[1]
local root_dir = root_file and vim.fs.dirname(root_file) or vim.fn.getcwd()

vim.lsp.start {
  name = 'nil_ls',
  cmd = { 'nil' },
  root_dir = root_dir,
  capabilities = require('user.lsp').make_client_capabilities(),
}
