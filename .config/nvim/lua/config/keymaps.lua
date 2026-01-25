-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = {
  noremap = true,
  silent = true,
}

vim.keymap.set("v", "J", "mzJ`z", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', opts)
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', opts)

vim.keymap.set("i", "<S-Tab>", "<C-d>", opts)

-- When in character-wise or block-wise visual mode,
-- substitute only within exact bounds
vim.keymap.set("v", ":s", function()
  local mode = vim.fn.mode()
  -- \22 is Ctrl-V control character
  if mode == "v" or mode == "\22" then
    return ":s/\\%V"
    -- When in line-wise visual mode,
    -- acts as normal substitution command
  elseif mode == "V" then
    return ":s"
  end
end, { expr = true })
