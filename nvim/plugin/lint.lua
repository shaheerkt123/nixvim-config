local lint = require('lint')

lint.linters_by_ft = {
  lua = { 'luacheck' },
  go = { 'golangci-lint' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function()
    local ft = vim.bo.filetype
    local linters = lint.linters_by_ft[ft]
    if linters then
      local executable_linters = {}
      for _, linter in ipairs(linters) do
        -- Check if it's executable AND if nvim-lint knows about it
        if vim.fn.executable(linter) == 1 and lint.linters[linter] then
          table.insert(executable_linters, linter)
        end
      end
      if #executable_linters > 0 then
        pcall(lint.try_lint, executable_linters)
      end
    end
  end,
})
