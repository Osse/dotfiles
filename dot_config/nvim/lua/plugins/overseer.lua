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
        }
    }
}
