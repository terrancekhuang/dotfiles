-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Clipboard
vim.opt.clipboard = ""

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per tab
vim.opt.softtabstop = 4 -- number of spaces in tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces

-- UI Config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.relativenumber = true

-- Searching
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Timeout
vim.opt.timeoutlen = 100
vim.opt.ttimeoutlen = 0

-- Scrolling
vim.opt.scrolloff = 8
