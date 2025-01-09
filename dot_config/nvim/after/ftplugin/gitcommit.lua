local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

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

local function find_prefix()
    -- Surely there's a better way, part 1
    local is_insert_mode = vim.api.nvim_get_mode().mode:sub(1,1) == "i"

    local files = get_changed_files()
    local git_command = { "git", "log", "--format=%h %s", "--", unpack(files) }
    if #files == 1 then
        table.insert(git_command, 2, "--follow")
    end

    require "telescope.builtin".git_commits({
        git_command = git_command,
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local ref = get_prefix(selection.value)

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
vim.keymap.set({'n', 'i'}, '<C-X>', find_prefix)

