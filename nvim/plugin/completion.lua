if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local cmp = require('cmp')

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local function has_words_before()
  local unpack_ = unpack or table.unpack
  local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

---@param source string|table
local function complete_with_source(source)
  if type(source) == 'string' then
    cmp.complete { config = { sources = { { name = source } } } }
  elseif type(source) == 'table' then
    cmp.complete { config = { sources = { source } } }
  end
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(-4)
      else
        complete_with_source('buffer')
      end
    end, { 'i', 'c', 's' }),
    ['<C-f>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(4)
      else
        complete_with_source('path')
      end
    end, { 'i', 'c', 's' }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end, { 'i', 'c', 's' }),
    ['<C-y>'] = cmp.mapping.confirm {
      select = true,
    },
  },
  sources = cmp.config.sources {
    -- The insertion order influences the priority of the sources
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'path' },
  },
  enabled = function()
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'path' },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol', keyword_length = 3 },
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

vim.keymap.set({ 'i', 'c', 's' }, '<C-n>', cmp.complete, { noremap = false, desc = '[cmp] complete' })
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
