-- [[ OPTIONS ]]
-- See `:help options` | `:help option-list` | `:help vim.opt`

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.lsp.set_log_level("OFF")
vim.lsp.log_levels = "OFF"
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"
-- vim.g.autoformat = true
-- vim.g.snacks_animate = true
-- vim.g.lazyvim_picker = "auto" -- ("fzf" | "telescope")
-- vim.g.lazyvim_cmp = "auto" -- ("blink.cmp" | "nvim-cmp")
-- vim.g.ai_cmp = true
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
-- vim.g.root_lsp_ignore = { "copilot" }
-- vim.g.deprecation_warnings = false
-- vim.g.trouble_lualine = true
-- vim.opt.autowrite = true
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync clipboard between OS and Neovim.
vim.opt.completeopt = "menu,menuone,noselect" -- Set completeopt to have a better completion experience.
vim.opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions.

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s). (default: false)
vim.opt.confirm = true

vim.opt.cursorline = true -- Highlight the current line.
vim.opt.expandtab = true -- Convert tabs to spaces.
vim.opt.foldmethod = "manual"
-- vim.opt.fillchars = {
--   foldopen = "",
--   foldclose = "",
--   fold = " ",
--   foldsep = " ",
--   diff = "╱",
--   eob = " ",
-- }
-- vim.opt.foldlevel = 99
-- vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
-- vim.opt.formatoptions = "jcroqlnt" -- tcqj
-- vim.opt.grepformat = "%f:%l:%c:%m"
-- vim.opt.grepprg = "rg --vimgrep"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term. (default: false)
vim.opt.ignorecase = true

vim.opt.inccommand = "split" -- Preview substitutions live. For example `:%s/searchterm` splits a new window.

-- vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- Companion to wrap, don't split words.
vim.opt.list = true
vim.opt.mouse = "a" -- Enable mouse mode, can be useful for resizing splits for example.
vim.opt.number = true -- Show line numbers
vim.opt.pumblend = 10
vim.opt.pumheight = 10 -- Popup menu height.
vim.opt.relativenumber = true -- Set relative line numbers. Useful when moving across lines.
vim.opt.ruler = true -- Enable ruler.
vim.opt.scrolloff = 4 -- Minimal Minimumer of screen lines to keep above and below the cursor.
-- vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- vim.opt.shiftround = true
vim.opt.shiftwidth = 2 -- The number of spaces inserted for each indentation with << and >> keys in normal mode.
-- vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false
vim.opt.sidescrolloff = 8 -- Minimal number of screen columns either side of cursor if wrap is `false`.
vim.opt.signcolumn = "yes" -- Keep signcolumn on by default. Otherwise it would shift the each time.
vim.opt.smartcase = true
vim.opt.smartindent = true -- Make indenting smarter again.
-- vim.opt.spelllang = { "en" }

-- Configure how new splits should be opened. (default: false)
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.splitright = true

-- vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
vim.opt.tabstop = 2 -- Insert n spaces for a tab with <TAB> key in insert mode.
vim.opt.termguicolors = true -- Set termguicolors to enable highlight groups.
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time. (default: 1000)
vim.opt.undofile = true -- Save undo history.
-- vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- Decrease update time. (default: 4000)
vim.opt.virtualedit = "block" -- Continue to move cursor even if there are no characters in visual block mode.
-- opt.wildmode = "longest:full,full" -- Command-line completion mode
-- opt.winminwidth = 5 -- Minimum window width
vim.opt.wrap = false -- Enables line wrap.
-- if vim.fn.has("nvim-0.10") == 1 then
--   opt.smoothscroll = true
--   opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
--   opt.foldmethod = "expr"
--   opt.foldtext = ""
-- else
--   opt.foldmethod = "indent"
--   opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
-- end
-- vim.g.markdown_recommended_style = 0

vim.g.have_nerd_font = true

-- It is strongly advised to eagerly disable netrw, due to race conditions at vim startup.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.autoindent = true -- Copy indent from current line when starting new one.
vim.opt.backspace = "indent,eol,start" -- Allow backspace on.
vim.opt.backup = false -- Creates a backup file. (default: false)
vim.opt.breakindent = true
vim.opt.cmdheight = 2 -- More space in the Neovim command line for displaying messages.
vim.opt.colorcolumn = "120" -- Ruler width.
vim.opt.cursorlineopt = "line,number" -- Highlight both line and linenumber.
vim.opt.fileencoding = "utf-8" -- The encoding written to a file.
vim.opt.guifont = "HackNerdFontMono:h17"
vim.opt.hlsearch = true -- Set highlight on search.
vim.opt.incsearch = true

-- Hyphenated words recognized by searches. (default: does not include '-')
vim.opt.isfname:append("@-@")
vim.opt.iskeyword:append("-")

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.numberwidth = 4 -- Set number column width.
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim in case Vim still in use.
vim.opt.showtabline = 3 -- Always show tabs.
vim.opt.softtabstop = 2 -- The number of spaces that a tab counts for while performing editing operations.
vim.opt.swapfile = false -- Creates a swapfile. (default: true)
-- vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.whichwrap = "bs<>[]hl" -- Which "horizontal" keys are allowed to travel to prev/next line. (default: 'b,s')
vim.opt.writebackup = false -- If a file is being edited, it is not allowed to be edited. (default: true)

-- Add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- LSP related options for LazyVim
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
