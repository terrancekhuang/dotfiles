-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = {
  noremap = true,
  silent = true,
}

-- Keeping it centered
vim.keymap.set("n", "J", "mzJ`z", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Copy and paste from main clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', opts)
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', opts)

-- Moving blocks of code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Unindent with shift tab
vim.keymap.set("i", "<S-Tab>", "<C-d>", opts)

vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy full file path to clipboard" })

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

vim.api.nvim_create_user_command("W", "SudaWrite", {})

-- gf only grabs up to the first whitespace by default (Vim's 'isfname'
-- doesn't include space), so paths like "~/foo/bar baz/qux.md" break it.
-- If the cursor is inside a quoted string or a markdown (...) link, use
-- that whole span as the path instead; otherwise fall back to plain gf.
local function smart_gf()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed, cursor col

  local function find_span()
    for _, pat in ipairs({ '"([^"]+)"', "'([^']+)'", "%[.-%]%(([^%)]+)%)" }) do
      local start_idx = 1
      while true do
        local s, e, capture = line:find(pat, start_idx)
        if not s then
          break
        end
        if col >= s and col <= e then
          return capture
        end
        start_idx = e + 1
      end
    end
  end

  local path = find_span()
  if path then
    local expanded = vim.fn.expand(path)
    if vim.fn.filereadable(expanded) == 1 or vim.fn.isdirectory(expanded) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(expanded))
      return
    end
  end

  vim.cmd("normal! gf")
end

vim.keymap.set("n", "gf", smart_gf, { desc = "Go to file (handles quoted/linked paths with spaces)" })
