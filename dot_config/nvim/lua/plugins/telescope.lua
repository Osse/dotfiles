return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
        },
        'nvim-telescope/telescope-ui-select.nvim'
    },
    opts = {
        extensions = {
            ["ui-select"] =  {}
        },
        pickers = {
            buffers = {
                sort_lastused = true
            }
        },
        defaults = {
            cache_picker = {
                num_pickers = 5
            },
            mappings = {
                i = {
                    ["<C-u>"] = false
                }
            }
        }
    },
    init = function()
        local r = require("telescope")
        r.load_extension("ui-select")
        r.load_extension("arglist")
    end
}
