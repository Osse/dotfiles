local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function get_reference(commit)
    local cmd = vim.system({ "git", "show", "-s", "--format=reference", commit }, { text = true })
    local ref = cmd:wait().stdout
    ref = ref and ref:sub(1, -2)
    return ref
end

local function insert_reference()
    -- Surely there's a better way, part 1
    local is_insert_mode = vim.api.nvim_get_mode().mode:sub(1,1) == "i"

    require "telescope.builtin".git_commits({
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local ref = get_reference(selection.value)

                if ref then
                    vim.schedule(function()
                        -- Surely there's a better way, part 2
                        if is_insert_mode then
                            vim.cmd [[startinsert]]
                        end
                        vim.api.nvim_put({ref}, "", false, true)
                    end)
                end
            end)
            return true
        end
    })
end

vim.keymap.set({'n', 'i'}, '<C-R>', insert_reference)

