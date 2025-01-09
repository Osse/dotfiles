return {
    'Osse/cmake-tools.nvim',
    branch = "all-fixes",
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        cmake_generate_options = {},
        cmake_regenerate_on_save = false,
        cmake_executor = {
            name = "overseer",
        },
        cmake_runner = {
            name = "overseer",
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "CMakeToolsEnterProject",
            group = vim.api.nvim_create_augroup("minvimrc", { clear = true }),
            callback = function(ev)
                vim.keymap.set('n', '<F5>', ':CMakeRun<CR>')
                vim.keymap.set('n', '<F6>', ':CMakeBuild<CR>')
            end
        })
    end
}
