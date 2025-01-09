return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
        ensure_installed = { "c", "cmake", "cpp", "just", "lua", "markdown", "python", "qmljs", "qmldir", "rust", "vim", "vimdoc", "toml", "yaml" },
        sync_install = false,
        highlight = { enable = true },
        indent = {
            enable = true,
            disable = { "cmake" }
        },
    }
}
