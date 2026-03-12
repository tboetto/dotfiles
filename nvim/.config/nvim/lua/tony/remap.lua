vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.g.winresizer_start_key = '<C-w>e'

vim.cmd [[
  augroup xresources
  autocmd!
  autocmd BufWritePost *Xresources !xrdb %
  augroup end
]]
