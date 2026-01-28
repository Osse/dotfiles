return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    branch = 'main',
    opts = {
        highlight = { enable = true },
        indent = {
            enable = true,
            disable = { "cmake" }
        },
    }
}
