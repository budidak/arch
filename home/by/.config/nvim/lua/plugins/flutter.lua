-- Tools to help create flutter apps in neovim using the native lsp
-- https://github.com/nvim-flutter/flutter-tools.nvim

return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
  },
  opts = {
    widget_guides = {
      enabled = true,
    },
    dev_log = {
      notify_errors = true,
      focus_on_open = true,
    },
    lsp = {
      color = {
        enabled = true,
        background = true,
      },
    },
  },
}
