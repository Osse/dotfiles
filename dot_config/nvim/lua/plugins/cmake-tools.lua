local function on_new_task(task)
    local o = require("overseer")

    task:subscribe("on_complete", function(t, result)
        if result == "SUCCESS" or result == "CANCELED" then
            o.close()
            vim.cmd("cclose")
        end
    end)

    vim.cmd("cclose")
    o.open( { enter = false, focus_task_id = task.id })
end

return {
    'Civitasv/cmake-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        cmake_generate_options = {},
        cmake_regenerate_on_save = false,
        cmake_executor = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    if task.name:find("--build") then
                        local t = cm.get_build_target()
                        if t and t[1] then
                            task.name = "Build " .. t[1]
                        else
                            task.name = "Build default"
                        end
                    end
                    on_new_task(task)
                end,
                new_task_opts = {
                    strategy = {
                        "jobstart"
                    },
                }
            },
        },
        cmake_runner = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    task.name = "Run " .. (cm.get_build_target()[1] or "default") .. " " .. table.concat(cm.get_launch_args(), " ")
                    task.cwd = vim.fn.getcwd()
                    on_new_task(task)
                end,
                new_task_opts = {
                    strategy = {
                        "jobstart"
                    },
                }
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
                vim.keymap.set('n', '<F7>', function() cm.build_current_file({}) end)
                vim.keymap.set('n', '<F18>', function() cm.stop_executor({}) end)
                vim.keymap.set('n', '<S-F6>', function() cm.stop_executor({}) end)
            end
        })
    end
}
