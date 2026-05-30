if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true
-- print('DEBUG: completion.lua loaded')

local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

luasnip.config.setup {
  history = true,
  updateevents = 'TextChanged,TextChangedI',
}

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local function has_words_before()
  local unpack_ = unpack or table.unpack
  local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
    -- autocomplete = false,
  },
  performance = {
    debounce = 150,
    fetching_timeout = 1000,
    max_view_entries = 30,
  },
  formatting = {
    format = lspkind.cmp_format {
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
      menu = {
        buffer = '[BUF]',
        nvim_lsp = '[LSP]',
        nvim_lsp_signature_help = '[LSP]',
        nvim_lsp_document_symbol = '[LSP]',
        nvim_lua = '[API]',
        path = '[PATH]',
        luasnip = '[SNIP]',
      },
    },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000, keyword_length = 1 },
    { name = 'luasnip', priority = 750 },
    { name = 'nvim_lsp_signature_help', priority = 500 },
  }, {
    { name = 'buffer', keyword_length = 3, priority = 250 },
    { name = 'path', priority = 250 },
  }),
  enabled = function()
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources({
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'path' },
  }),
})

cmp.setup.filetype('go', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000, keyword_length = 1 },
    { name = 'luasnip', priority = 750 },
    { name = 'nvim_lsp_signature_help', priority = 500 },
  }, {
    { name = 'buffer', keyword_length = 3, priority = 250 },
    { name = 'path', priority = 250 },
  }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
    { name = 'cmdline_history' },
  },
  view = {
    entries = { name = 'wildmenu', separator = '|' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'cmdline_history' },
    { name = 'path' },
  },
})

local function complete_with_source(source)
  cmp.complete {
    config = {
      sources = {
        { name = source },
      },
    },
  }
end

-- vim.keymap.set({ 'i', 'c', 's' }, '<C-n>', cmp.complete, { noremap = false, desc = '[cmp] complete' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-f>', function()
  complete_with_source('path')
end, { noremap = false, desc = '[cmp] path' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-o>', function()
  complete_with_source('nvim_lsp')
end, { noremap = false, desc = '[cmp] lsp' })
vim.keymap.set({ 'c' }, '<C-h>', function()
  complete_with_source('cmdline_history')
end, { noremap = false, desc = '[cmp] cmdline history' })
vim.keymap.set({ 'c' }, '<C-c>', function()
  complete_with_source('cmdline')
end, { noremap = false, desc = '[cmp] cmdline' })
