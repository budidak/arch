-- A collection of QoL plugins for Neovim
-- https://github.com/folke/snacks.nvim

return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
