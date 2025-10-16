return {
  "folke/flash.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" }, false },

    -- Use 'gs' instead
    {
      "gs",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "gS",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
  },
}
