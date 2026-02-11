return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    checkbox = {
      enabled = true,
    },
    latex = {
      enabled = true,
      render_modes = false,
      converter = { "utftex", "latex2text" },
      highlight = "RenderMarkdownMath",
      position = "center",
      top_pad = 0,
      bottom_pad = 0,
    },
  },
}
