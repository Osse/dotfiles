-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = "ø"
vim.g.maplocalleader = "æ"

local minvimrc_augroup = vim.api.nvim_create_augroup("minvimrc", { clear = true })

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "jellybeans" } },
})


-- Options
vim.opt.suffixes = '.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc'
vim.opt.sessionoptions:remove({'options', 'blank', 'winsize' })
vim.opt.sessionoptions:append('winpos')
vim.opt.linebreak = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevelstart = 99
vim.opt.hlsearch = true
vim.opt.showmatch = true
vim.opt.wildmode = 'list:longest'
vim.opt.completeopt:remove('preview')
vim.opt.cinoptions:append('(0,u0,g0,N-s')
vim.opt.showbreak = '>\\'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.undofile = true

local n = function(lhs, rhs)
    vim.keymap.set('n', lhs, rhs, {})
end
local v = function(lhs, rhs)
    vim.keymap.set('v', lhs, rhs, {})
end

-- Mappings
n('!', '?')
n('S', '/')
n('<Space>', '<C-W><C-W>')
n('ZA', ':qa!<CR>')
n('¤', '$')
n('æ', '^')
n('<Leader>p', "p=']")
v('>', '>gv')
v('<', '<gv')
n('c)', 'v)?[.!?]\\+?s-1<CR>c')
n('g)', ')gE')
n('g(', '(gE')
n('<C-Left>', '<C-O>')
n('<C-Right>', '<C-I>')
n('<C-Down>', '<C-W><Down>')
n('<C-Up>', '<C-W><Up>')
n('<Esc>O5D', '<C-W><Left>')
n('<Esc>O5C', '<C-W><Right>')
n('<Esc>O5B', '<C-W><Down>')
n('<Esc>O5A', '<C-W><Up>')
-- Toggles and other stuff {{{
n('<F1>', ':he ')
n('<F2>', ':set invnumber number?<CR>')
n('<F3>', ':set invrelativenumber relativenumber?<CR>')
n('<F6>', ':set invspell spell?<CR>')
n('<F7>', ':set invwrap wrap?<CR>')
n('<silent>', '<F9> :wall <Bar> make<CR><CR><CR>:botright cwindow<CR>')
-- }}}
n('<C-W>]', ':vsplit<CR>:tag<CR>')
n('<silent>', '<C-l> :noh<CR><C-l>')
n("'", '`')
n('`', "'")
n('<leader>q', 'gqap')

local tb = require('telescope.builtin')
n('<C-P>', tb.git_files)
n('Q', tb.buffers)
n('<Leader>f', function() tb.grep_string({ word_match = "-w" }) end)
n('<Leader>F', tb.live_grep)

-- Autocmds

local function map_q(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'q', ':q<CR>', opts)
end

vim.api.nvim_create_autocmd("CmdwinEnter", {
    group = minvimrc_augroup,
    callback = map_q
})

vim.api.nvim_create_autocmd("Filetype", {
    pattern = "qf",
    group = minvimrc_augroup,
    callback = map_q
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = minvimrc_augroup,
    callback = function(ev)
        vim.cmd("cwindow")
    end
})
