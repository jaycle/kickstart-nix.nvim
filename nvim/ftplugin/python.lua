-- Check if lua-language-server is available
if vim.fn.executable('pylsp') ~= 1 then
  return
end

vim.lsp.start {
  name = 'pylsp',
  cmd = { 'pylsp' },
}
