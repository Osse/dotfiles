vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")

-- Start Plug
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('tpope/vim-surround')
Plug('tomtom/tcomment_vim')
Plug('godlygeek/tabular')
Plug('SirVer/ultisnips')
Plug('honza/vim-snippets')
Plug('junegunn/fzf', { ['dir'] = '~/.fzf', ['do'] = './install --all' })
Plug('junegunn/fzf.vim')
Plug('tpope/vim-repeat')
Plug('tpope/vim-fugitive')
Plug('Osse/double-tap')
Plug('nanotech/jellybeans.vim')
Plug('mhinz/vim-startify')
Plug('richq/vim-cmake-completion')
Plug('PotatoesMaster/i3-vim-syntax')
Plug('PProvost/vim-ps1')
Plug('rust-lang/rust.vim')
Plug('cespare/vim-toml', { ['branch'] = 'main' })
vim.call('plug#end')

vim.g.jellybeans_overrides = {
    ['StatusLine'] = { ['attr'] = 'bold' },
    ['StatusLineNC'] = { ['attr'] = 'bold' }
}
vim.cmd.colorscheme("jellybeans")

-- Options
vim.opt.ruler = true
vim.opt.suffixes = '.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc'
vim.opt.backspace = 'indent,eol,start'
vim.opt.history = 50
vim.opt.sessionoptions:remove({'options', 'blank', 'winsize' })
vim.opt.sessionoptions:append('winpos')
vim.opt.autoindent = true
vim.opt.linebreak = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevelstart = 99
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.wildmode = 'list:longest'
vim.opt.hidden = true
vim.opt.joinspaces = false
vim.opt.completeopt:remove('preview')
vim.opt.cinoptions:append('(0,u0,g0,N-s')
vim.opt.pastetoggle = '<F4>'
vim.opt.showbreak = '>\\'
vim.opt.laststatus = 2
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 100
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.undofile = true

-- Mappings
vim.cmd([[
let mapleader="ø"
nnoremap !         ?
nnoremap S         /
nnoremap <Space>   <C-W><C-W>
map      Y         y$
noremap  ZA        :qa!<CR>
noremap  ¤         $
noremap  æ         ^
noremap  <Leader>p p=']
vnoremap >         >gv
vnoremap <         <gv
nnoremap c)        v)?[.!?]\+?s-1<CR>c
nnoremap g)        )gE
nnoremap g(        (gE
nnoremap <C-Left>  <C-W><Left>
nnoremap <C-Right> <C-W><Right>
nnoremap <C-Down>  <C-W><Down>
nnoremap <C-Up>    <C-W><Up>
nnoremap <Esc>O5D  <C-W><Left>
nnoremap <Esc>O5C  <C-W><Right>
nnoremap <Esc>O5B  <C-W><Down>
nnoremap <Esc>O5A  <C-W><Up>
" Toggles and other stuff {{{
nnoremap <F1> :he 
nnoremap <F2> :set invnumber number?<CR>
nnoremap <F3> :set invrelativenumber relativenumber?<CR>
nnoremap <F5> :set invlist list?<CR>
nnoremap <F6> :set invspell spell?<CR>
nnoremap <F7> :set invwrap wrap?<CR>
nnoremap <silent> <F9> :wall <Bar> make<CR><CR><CR>:botright cwindow<CR>
" }}}
nnoremap <C-W>] :vsplit<CR>:tag<CR>
nnoremap <silent> <C-l> :noh<CR><C-l>
nnoremap ' `
nnoremap ` '
nnoremap <leader>q gqap
]])
