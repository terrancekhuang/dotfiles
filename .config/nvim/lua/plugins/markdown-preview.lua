return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0 -- don't close preview when switching buffers
      vim.g.mkdp_combine_preview = 0 -- don't reuse preview tab
    end,
    ft = { "markdown" },
  },
}
