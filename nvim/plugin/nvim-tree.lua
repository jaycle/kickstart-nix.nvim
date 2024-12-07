require('nvim-tree').setup({
  view = {
    preserve_window_proportions = true,
  },
  actions = {
    open_file = {
      resize_window = false,
    },
  },
})

vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>T', ':NvimTreeFindFile<CR>', { silent = true, noremap = true })
