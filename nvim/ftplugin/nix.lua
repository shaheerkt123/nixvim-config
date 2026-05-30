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

local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
local root_file = vim.fs.find(root_files, { upward = true, path = buffer_dir })[1]
local root_dir = root_file and vim.fs.dirname(root_file) or vim.fn.getcwd()

vim.lsp.start {
  name = 'nil_ls',
  cmd = { 'nil' },
  root_dir = root_dir,
  capabilities = require('user.lsp').make_client_capabilities(),
}
