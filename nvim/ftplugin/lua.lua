vim.bo.comments = ':---,:--'

local lua_ls_cmd = 'lua-language-server'

-- Check if lua-language-server is available
if vim.fn.executable(lua_ls_cmd) ~= 1 then
  return
end

local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
  '.git',
}

local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
local root_file = vim.fs.find(root_files, { upward = true, path = buffer_dir })[1]
local root_dir = root_file and vim.fs.dirname(root_file) or vim.fn.getcwd()

vim.lsp.start {
  name = 'lua_ls',
  cmd = { lua_ls_cmd },
  root_dir = root_dir,
  capabilities = require('user.lsp').make_client_capabilities(),
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global, etc.
        globals = {
          'vim',
          'describe',
          'it',
          'assert',
          'stub',
        },
        disable = {
          'duplicate-set-field',
        },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      hint = { -- inlay hints (supported in Neovim >= 0.10)
        enable = true,
      },
    },
  },
}
