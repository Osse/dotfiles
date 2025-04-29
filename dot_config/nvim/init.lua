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
vim.opt.switchbuf = "useopen"

local n = function(lhs, rhs)
    vim.keymap.set('n', lhs, rhs, {})
end
local v = function(lhs, rhs)
    vim.keymap.set('v', lhs, rhs, {})
end

-- Mappings
n('!', '?')
n('S', '/')
n('<Space>', '<C-W>w')
n('<C-Space>', '<C-W>W')
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
n('<F7>', ':set invwrap wrap?<CR>')
n('<silent>', '<F9> :wall <Bar> make<CR><CR><CR>:botright cwindow<CR>')
-- }}}
n('<C-W>]', ':vsplit<CR>:tag<CR>')
n('<silent>', '<C-l> :noh<CR><C-l>')
n("'", '`')
n('`', "'")
n('<leader>q', 'gqap')

local tb = require('telescope.builtin')

local is_inside_work_tree = {}

local function project_files(opts)
  opts = opts or {} -- define here if you want to define something

  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    tb.git_files(opts)
  else
    tb.find_files(opts)
  end
end

n('<C-P>', project_files)
n('<Leader><C-P>', function() project_files({ default_text = vim.fn.expand("<cword>")}) end)
n('<Leader>.<C-P>', function() tb.find_files({ cwd = vim.fn.expand("%:p:h")}) end)
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

-- LSP
vim.lsp.enable({'clangd', 'lua-language-server', 'pylsp', 'rust-analyzer'})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<leader>gd', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>h', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, opts)
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>=', vim.lsp.buf.format, opts)

        if client.name == "clangd" then
            vim.keymap.set('n', '<F4>', function()
                local method_name = 'textDocument/switchSourceHeader'
                local params = vim.lsp.util.make_text_document_params(ev.buf)
                client.request(method_name, params, function(err, result)
                    if err then
                        error(tostring(err))
                    end
                    if not result then
                        vim.notify('corresponding file cannot be determined')
                        return
                    end
                    vim.cmd.edit(vim.uri_to_fname(result))
                end, ev.buf)
            end, opts)

            vim.api.nvim_create_user_command('ClangdShowSymbolInfo', function()
                local win = vim.api.nvim_get_current_win()
                local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
                client.request('textDocument/symbolInfo', params, function(err, res)
                    if err or #res == 0 then
                        -- Clangd always returns an error, there is not reason to parse it
                        return
                    end
                    local container = string.format('container: %s', res[1].containerName) ---@type string
                    local name = string.format('name: %s', res[1].name) ---@type string
                    vim.lsp.util.open_floating_preview({ name, container }, '', {
                        height = 2,
                        width = math.max(string.len(name), string.len(container)),
                        focusable = false,
                        focus = false,
                        border = 'single',
                        title = 'Symbol Info',
                    })
                end, ev.buf)
            end, {})
        end
    end
})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count = -1, float = true}) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count = 1, float = true}) end)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
