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

function code_context()
    local opts = {}

    if vim.bo.filetype == "yaml" then
        opts.type_patterns = { "block_mapping_pair" }
        opts.transform_fn = function(text, node)
            -- Strip ":" from parent nodes and ": some value" or ": |" from the current node
            local i = string.find(text, ":") or 0
            return string.sub(text, 1, i-1)
        end
    elseif vim.bo.filetype == "qml" then
        opts.type_patterns = { "ui_object_definition" }
    end
    -- else the defaults are good enough for now

    return require("nvim-treesitter").statusline(opts)
end

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        { 'tpope/vim-surround' },
        { 'godlygeek/tabular' },
        { 'SirVer/ultisnips' },
        { 'honza/vim-snippets' },
        {
            'junegunn/fzf.vim',
            dependencies =  {
                { 'junegunn/fzf', { ['dir'] = '~/.fzf', ['do'] = './install --bin' } }
            }
        },
        { 'tpope/vim-repeat' },
        { 'tpope/vim-fugitive' },
        { 'Osse/double-tap' },
        {
            'nanotech/jellybeans.vim',
            lazy = false,
            priority = 1000,
            init = function()
                vim.cmd.colorscheme("jellybeans")
            end
        },
        {
            'mhinz/vim-startify',
            init = function()
                vim.g.startify_relative_path = 1
                vim.g.startify_bookmarks = {
                    { ['m'] = '~/.vim/vimrc' },
                    { ['n'] = '~/.config/nvim/init.lua' },
                    { ['i'] = '~/.i3/config' },
                    { ['z'] = '~/.zshrc' },
                    { ['b'] = '~/.bashrc' },
                    { ['g'] = '~/.gitconfig' },
                }
                vim.g.startify_change_to_dir = 0
                vim.g.startify_change_to_vcs_root = 1
            end
        },
        { 'richq/vim-cmake-completion' },
        { 'PotatoesMaster/i3-vim-syntax' },
        { 'PProvost/vim-ps1' },
        { 'rust-lang/rust.vim' },
        { 'fladson/vim-kitty' },
        {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            opts = {
                ensure_installed = { "c", "cmake", "cpp", "just", "lua", "markdown", "python", "qmljs", "qmldir", "rust", "vim", "vimdoc", "toml", "yaml" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            }
        },
        {
            'mikesmithgh/kitty-scrollback.nvim',
            enabled = true,
            lazy = true,
            cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
            event = { 'User KittyScrollbackLaunch' },
            opts = {}
        },
        {
            'neovim/nvim-lspconfig',
            config = function()
                -- Setup language servers.
                local lspconfig = require('lspconfig')

                -- Rust
                lspconfig.rust_analyzer.setup {
                    -- Server-specific settings. See `:help lspconfig-setup`
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                            },
                            imports = {
                                group = {
                                    enable = false,
                                },
                            },
                            completion = {
                                postfix = {
                                    enable = false,
                                },
                            },
                        },
                    },
                }

                -- C++
                lspconfig.clangd.setup({
                    vim.api.nvim_create_autocmd('LspAttach', {
                        group = vim.api.nvim_create_augroup('UserLspConfigClangd', {}),
                        callback = function(ev)
                            local opts = { buffer = ev.buf }
                            vim.keymap.set('n', '<F4>', ':ClangdSwitchSourceHeader<CR>', opts)
                        end,
                    })
                })

                -- Global mappings.
                -- See `:help vim.diagnostic.*` for documentation on any of the below functions
                vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
                vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

                -- Use LspAttach autocommand to only map the following keys
                -- after the language server attaches to the current buffer
                vim.api.nvim_create_autocmd('LspAttach', {
                    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                    callback = function(ev)
                        -- Enable completion triggered by <c-x><c-o>
                        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                        -- Buffer local mappings.
                        -- See `:help vim.lsp.*` for documentation on any of the below functions
                        local opts = { buffer = ev.buf }
                        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                        vim.keymap.set('n', '<leader>wl', function()
                            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                        end, opts)
                        --vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
                        vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, opts)
                        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                        vim.keymap.set('n', '<leader>=', function()
                            vim.lsp.buf.format { async = true }
                        end, opts)
                    end,
                })
            end
        },
        {
            "hrsh7th/nvim-cmp",
            -- load cmp on InsertEnter
            event = "InsertEnter",
            -- these dependencies will only be loaded when cmp loads
            -- dependencies are always lazy-loaded unless specified otherwise
            dependencies = {
                'neovim/nvim-lspconfig',
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
            },
            config = function()
                local cmp = require'cmp'
                cmp.setup({
                    snippet = {
                        -- REQUIRED by nvim-cmp. get rid of it once we can
                        expand = function(args)
                            vim.fn["vsnip#anonymous"](args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-f>'] = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-e>'] = cmp.mapping.abort(),
                        -- Accept currently selected item.
                        -- Set `select` to `false` to only confirm explicitly selected items.
                        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                    }),
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                    }, {
                        { name = 'path' },
                    }, {
                        {
                            name = 'buffer',
                            option = {
                                get_bufnrs = function()
                                    local bufs = {}
                                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                                        bufs[vim.api.nvim_win_get_buf(win)] = true
                                    end
                                    return vim.tbl_keys(bufs)
                                end
                            }
                        },
                    }),
                    experimental = {
                        ghost_text = true,
                    },
                })

                -- Enable completing paths in :
                cmp.setup.cmdline(':', {
                    sources = cmp.config.sources({
                        { name = 'path' }
                    })
                })
            end
        },
        {
            'stevearc/overseer.nvim',
            opts = {}
        },
        {
            dir = '~/dev/cmake-tools.nvim',
            -- 'Osse/cmake-tools.nvim',
            -- branch = "all-fixes",
            dependencies = { 'nvim-lua/plenary.nvim' },
            opts = {
                cmake_generate_options = {},
                cmake_regenerate_on_save = false,
                cmake_executor = {
                    name = "overseer",
                    default_opts = {
                        overseer = {
                            new_task_opts = {},
                            on_new_task = function(task)
                                require("overseer").open( { enter = false, direction = "bottom" })
                            end,
                        },
                    },
                },
                cmake_runner = {
                    name = "overseer",
                },
            },
            init = function()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "CMakeToolsEnterProject",
                    group = minvimrc_augroup,
                    callback = function(ev)
                        vim.keymap.set('n', '<F5>', ':CMakeBuild<CR>')
                    end
                })
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.8',
            dependencies = {
                'nvim-lua/plenary.nvim',
                {
                    'nvim-telescope/telescope-fzf-native.nvim',
                    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
                },
                'nvim-telescope/telescope-ui-select.nvim'
            },
            opts = {
                extensions = {
                    ["ui-select"] =  {}
                },
                pickers = {
                    buffers = {
                        sort_lastused = true
                    }
                },
                defaults = {
                    cache_picker = {
                        num_pickers = 5
                    }
                }
            },
            init = function()
                require("telescope").load_extension("ui-select")
            end
        },
        {
            'nvim-lualine/lualine.nvim',
            opts = {
                options = {
                    theme = 'jellybeans'
                },
                extensions = { 'quickfix' },
                sections = {
                    lualine_c = {
                        {
                            'filename',
                            path = 1
                        }
                    },
                    lualine_x = { code_context }
                }
            }
        },
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

-- Mappings
vim.cmd([[
nnoremap !         ?
nnoremap S         /
nnoremap <Space>   <C-W><C-W>
noremap  ZA        :qa!<CR>
noremap  ¤         $
noremap  æ         ^
noremap  <Leader>p p=']
vnoremap >         >gv
vnoremap <         <gv
nnoremap c)        v)?[.!?]\+?s-1<CR>c
nnoremap g)        )gE
nnoremap g(        (gE
nnoremap <C-Left>  <C-O>
nnoremap <C-Right> <C-I>
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
nnoremap <F6> :set invspell spell?<CR>
nnoremap <F7> :set invwrap wrap?<CR>
nnoremap <silent> <F9> :wall <Bar> make<CR><CR><CR>:botright cwindow<CR>
" }}}
nnoremap <C-W>] :vsplit<CR>:tag<CR>
nnoremap <silent> <C-l> :noh<CR><C-l>
nnoremap ' `
nnoremap ` '
nnoremap <leader>q gqap

nnoremap <C-P> :Telescope git_files<CR>
nnoremap Q :Telescope buffers<CR>
nnoremap <Leader>f :Telescope grep_string<CR>
nnoremap <Leader>F :Telescope live_grep<CR>
]])

-- Autocmds

function map_q(ev)
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
