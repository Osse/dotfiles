local function on_new_task(task)
    local o = require("overseer")

    task:subscribe("on_complete", function(_, result)
        if result == "SUCCESS" then
            o.close()
            vim.cmd("cclose")
        end
    end)

    o.open( { enter = false, focus_task_id = task.id })
end

return {
    'Osse/cmake-tools.nvim',
    branch = "all-fixes",
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        cmake_generate_options = {},
        cmake_regenerate_on_save = false,
        cmake_executor = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    task.name = "Build " .. (cm.get_build_target() or "default")
                    on_new_task(task)
                end,
                new_task_opts = {
                    components = { { "on_output_quickfix", open = false, open_on_exit = "failure" }, "default" },
                }
            },
        },
        cmake_runner = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    task.name = "Run " .. (cm.get_build_target() or "default") .. " " .. table.concat(cm.get_launch_args(), " ")
                    on_new_task(task)
                end
            },
        },
        cmake_virtual_text_support = false,
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "CMakeToolsEnterProject",
            group = vim.api.nvim_create_augroup("minvimrc", { clear = true }),
            callback = function(_)
                local cm = require('cmake-tools')
                vim.keymap.set('n', '<F5>', function() cm.build({}) end)
                vim.keymap.set('n', '<F6>', function() cm.run({}) end)
                vim.keymap.set('n', '<F18>', function() cm.stop_executor({}) end)
                vim.keymap.set('n', '<S-F6>', function() cm.stop_executor({}) end)
            end
        })
    end
}
