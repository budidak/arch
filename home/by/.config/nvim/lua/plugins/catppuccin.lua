-- Soothing pastel theme for NeoVim.
-- https://github.com/catppuccin/nvim

return {
   "catppuccin/nvim",
   name = "catppuccin",
   lazy = false,
   priority = 1000,
   opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      background = { -- :h background
         light = "latte",
         dark = "macchiato",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
      term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
         enabled = false, -- dims the background color of inactive window
         shade = "dark",
         percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
         comments = { "italic" }, -- Change the style of comments
         conditionals = {},
         loops = {},
         functions = {},
         keywords = {},
         strings = {},
         variables = {},
         numbers = {},
         booleans = {},
         properties = {},
         types = {},
         operators = {},
         -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      color_overrides = {},
      custom_highlights = {},
      default_integrations = true,
      integrations = {
         aerial = true,
         alpha = true,
         blink_cmp = true,
         cmp = true,
         dap = true,
         dap_ui = true,
         dashboard = true,
         flash = true,
         fzf = true,
         gitsigns = true,
         grug_far = true,
         headlines = true,
         illuminate = true,
         indent_blankline = { enabled = true },
         leap = true,
         lsp_trouble = true,
         mason = true,
         markdown = true,
         mini = true,
         native_lsp = {
            enabled = true,
            virtual_text = {
               errors = { "italic" },
               hints = { "italic" },
               warnings = { "italic" },
               information = { "italic" },
               ok = { "italic" },
            },
            underlines = {
               errors = { "underline" },
               hints = { "underline" },
               warnings = { "underline" },
               information = { "underline" },
               ok = { "underline" },
            },
            inlay_hints = {
               background = true,
            },
         },
         navic = { enabled = true, custom_bg = "lualine" },
         neotest = true,
         neotree = true,
         noice = true,
         notify = true,
         nvimtree = true,
         semantic_tokens = true,
         snacks = {
            enabled = true,
            indent_scope_color = "blue", -- catppuccin color (eg. `lavender`) Default: text
         },
         telescope = true,
         treesitter = true,
         treesitter_context = true,
         which_key = true,
      },
   },
   specs = {
      {
         "akinsho/bufferline.nvim",
         optional = true,
         opts = function(_, opts)
            if (vim.g.colors_name or ""):find("catppuccin") then
               opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
            end
         end,
      },
   },
   config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
   end,
}
