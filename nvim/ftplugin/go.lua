local gopls_cmd = 'gopls'

-- Go indentation settings
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4

-- Check if gopls is available
if vim.fn.executable(gopls_cmd) ~= 1 then
  return
end

local root_files = {
  'go.work',
  'go.mod',
  '.git',
}

local root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]) or vim.fn.getcwd()

vim.lsp.start {
  name = 'gopls',
  cmd = { gopls_cmd },
  root_dir = root_dir,
  capabilities = require('user.lsp').make_client_capabilities(),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      completeUnimported = true,
      usePlaceholders = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

-- Organize imports on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want to increase this.
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.get_client_by_id(cid).offset_encoding)
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
    vim.lsp.buf.format { async = false }
  end,
})

-- Go specific keymaps
local keymap = vim.keymap
local function desc(description)
  return { noremap = true, silent = true, buffer = true, desc = description }
end

keymap.set('n', '<leader>gt', '<cmd>!go test -v ./...<cr>', desc('[g]o [t]est all'))
keymap.set('n', '<leader>gf', '<cmd>!go test -v %<cr>', desc('[g]o [t]est [f]ile'))
