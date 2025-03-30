return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
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
            ["ui-select"] = {}
        },
        pickers = {
            buffers = {
                sort_lastused = true,
                mappings = {
                    i = {
                        ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
                    }
                }
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
