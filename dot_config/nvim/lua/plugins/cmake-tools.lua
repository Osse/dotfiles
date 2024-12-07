return {
    'Osse/cmake-tools.nvim',
    branch = "all-fixes",
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
}
