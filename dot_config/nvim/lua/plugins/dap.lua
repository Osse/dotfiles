return {
    {
        'https://codeberg.org/mfussenegger/nvim-dap',
        keys = { '<F9>' },
        config = function()
            local dap = require("dap")

            vim.fn.sign_define('DapStopped', {text='→', linehl='Visual'})

            dap.adapters.lldb = {
                type = "executable",
                command = "lldb-dap-21",
            }

            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
            }
            dap.configurations.cpp = {
                {
                    name = "Launch current CMake launch target",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return require('cmake-tools').get_launch_target_path()
                    end,
                    args = function()
                        return require('cmake-tools').get_launch_args()
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = true,
                },
            }

            local map_cache = {}

            vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)

            local dap_mappings = {
                ['<F5>'] = dap.continue,
                ['<S-F5>'] = dap.terminate,
                ['<F17>'] = dap.terminate,
                ['<F7>'] = dap.repl.toggle,
                ['<F10>'] = dap.step_over,
                ['<F11>'] = dap.step_into,
                ['<S-F11>'] = dap.step_out,
                ['<F23>'] = dap.step_out,
            }

            dap.listeners.after.event_initialized["myconfig"] = function()
                vim.cmd('DapViewOpen')
                local map_index = {}
                for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
                    map_index[m.lhs] = m
                end
                for k, _ in pairs(dap_mappings) do
                    if map_index[k] then
                        map_cache[k] = map_index[k]
                    end
                end
                for k, v in pairs(dap_mappings) do
                    vim.keymap.set('n', k, v)
                end
            end

            local function restore_mappings()
                if vim.tbl_isempty(map_cache) then return end
                for k in pairs(dap_mappings) do
                    pcall(vim.keymap.del, 'n', k)
                end
                for _, v in pairs(map_cache) do
                    vim.fn.mapset(v)
                end
                map_cache = {}
            end

            dap.listeners.before.event_terminated["myconfig"] = restore_mappings
            dap.listeners.before.event_exited["myconfig"] = restore_mappings
        end
    },
    {
        "igorlfs/nvim-dap-view",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
    },
}
