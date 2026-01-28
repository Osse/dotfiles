return {
    'stevearc/overseer.nvim',
    keys = {
        { "<leader>O", "<cmd>OverseerToggle<cr>", desc = "Toggle Overseer" },
    },
    opts = {
        task_list = {
            bindings = {
                ["r"] = ":OverseerRun<CR>"
            },
        },
        actions = {
            ["close and open output in quickfix"] = {
                desc = "Close and open output in quickfix",
                condition = function(task)
                    return require('overseer.task_list.actions')["open output in quickfix"]["condition"](task)
                end,
                run = function(task)
                    require('overseer').close()
                    return require('overseer.task_list.actions')["open output in quickfix"]["run"](task)
                end,
            },
        }
    }
}
