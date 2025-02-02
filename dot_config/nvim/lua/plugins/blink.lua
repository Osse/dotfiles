return {
    'saghen/blink.cmp',
    version = '*',
    opts = {
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500
            },
            menu = {
                auto_show = function(ctx)
                    return ctx.mode ~= "cmdline" or not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
                end,
            },
        },
        keymap = {
            preset = 'super-tab',
        },
    },
}
