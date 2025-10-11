local function get_reference(commit)
    local cmd = vim.system({ "git", "show", "-s", "--format=reference", commit }, { text = true })
    local ref = cmd:wait().stdout
    ref = ref and ref:sub(1, -2)
    return ref
end

local function get_prefix(commit)
    local cmd = vim.system({ "git", "show", "-s", "--format=%s", commit }, { text = true })
    local subject = cmd:wait().stdout
    local pos = subject and subject:find(":")
    return subject and subject:sub(1, pos) .. " "
end

local function get_changed_files()
    local cmd = vim.system({"git", "diff", "--name-only", "--staged"}, { text = true })
    local output = cmd:wait().stdout
    if output == nil or output == '' then
        local cmd2 = vim.system({"git", "diff", "--name-only", "HEAD~", "HEAD"}, { text = true })
        output = cmd2:wait().stdout
        vim.print(output)
    end
    local files = {}
    if output == nil or output == '' then
        return files
    end
    for s in output:gmatch("[^\r\n]+") do
        table.insert(files, s)
    end
    vim.print(files)
    return files
end

local function insert_stuff(content)
    if content then
        local is_insert_mode = vim.api.nvim_get_mode().mode:sub(1,1) == "i"
        vim.schedule(function()
            -- Surely there's a better way
            if is_insert_mode then
                vim.cmd [[startinsert]]
            end
            vim.api.nvim_put({content}, "", false, true)
        end)
    end
end

local function insert_reference()
    require('fzf-lua').git_commits({
        actions = {
            ["default"] = function(selected, opts)
                local ref = get_reference(selected)
                insert_stuff(ref)
            end
        }
    })

    -- require "telescope.builtin".git_commits({
    --     attach_mappings = function(prompt_bufnr, _)
    --         local actions = require "telescope.actions"
    --         actions.select_default:replace(function()
    --             actions.close(prompt_bufnr)
    --             local action_state = require "telescope.actions.state"
    --             local selection = action_state.get_selected_entry()
    --             local ref = get_reference(selection.value)
    --             insert_stuff(ref)
    --         end)
    --         return true
    --     end
    -- })
end

local function find_prefix()
    local files = get_changed_files()
    local git_command = { "git", "log", "--format=%h %s", "--", unpack(files) }
    if #files == 1 then
        table.insert(git_command, 2, "--follow")
    end

    require('fzf-lua').git_commits({
        actions = {
            ["default"] = function(selected, opts)
                local prefix = get_prefix(selected)
                insert_stuff(prefix)
            end
        }
    })

    -- require "telescope.builtin".git_commits({
    --     git_command = git_command,
    --     attach_mappings = function(prompt_bufnr, _)
    --         local actions = require "telescope.actions"
    --         actions.select_default:replace(function()
    --             actions.close(prompt_bufnr)
    --             local action_state = require "telescope.actions.state"
    --             local selection = action_state.get_selected_entry()
    --             local prefix = get_prefix(selection.value)
    --             insert_stuff(prefix)
    --         end)
    --         return true
    --     end
    -- })
end

vim.keymap.set({'n', 'i'}, '<C-R>', insert_reference)
vim.keymap.set({'n', 'i'}, '<C-X>', find_prefix)

