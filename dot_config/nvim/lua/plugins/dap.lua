return {
    {
        'https://codeberg.org/mfussenegger/nvim-dap',
        config = function()
            vim.fn.sign_define('DapStopped', {text='→', linehl='Visual'})
        end
    },
    {
        "igorlfs/nvim-dap-view",
        opts = {},
    },
    {
        "igorlfs/nvim-dap-view",
        opts = {},
        dependencies = {
            { "nvim-neotest/nvim-nio" }
        }
    },
}
