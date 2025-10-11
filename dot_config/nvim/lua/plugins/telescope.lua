local is_inside_work_tree = {}

local tb = require('telescope.builtin')

local function project_files(opts)
  opts = opts or {} -- define here if you want to define something

  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    tb.git_files(opts)
  else
    tb.find_files(opts)
  end
end

return {
    'nvim-telescope/telescope.nvim',
    enabled = false,
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
        },
        'nvim-telescope/telescope-ui-select.nvim'
    },
    keys = {
        { "<leader>F", tb.live_grep, desc = "Live grep" },
        { "<Leader>f", function() tb.grep_string({ word_match = "-w" }) end, desc = "grep string" },
        { '<C-P>', project_files },
        { '<Leader><C-P>', function() project_files({ default_text = vim.fn.expand("<cword>")}) end },
        { '<Leader>.<C-P>', function() tb.find_files({ cwd = vim.fn.expand("%:p:h")}) end },
        { 'Q', tb.buffers, desc = "Switch buffers" }
    },
    opts = function()
        local actions = require "telescope.actions"
        return {
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
        }
    end,
    init = function()
        local r = require("telescope")
        r.load_extension("ui-select")
        r.load_extension("arglist")
    end
}
