local ocaml_ls_cmd = 'ocamllsp'

-- Check if lua-language-server is available
if vim.fn.executable(ocaml_ls_cmd) ~= 1 then
  return
end

vim.lsp.start {
  name = 'ocamllsp',
  cmd = { ocaml_ls_cmd },
}
-- require'lspconfig'.ocamllsp.setup{}
