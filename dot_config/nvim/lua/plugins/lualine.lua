local ft_opts = {
    yaml = {
        type_patterns = { "block_mapping_pair" },
        transform_fn = function(text, node)
            -- Strip ":" from parent nodes and ": some value" or ": |" from the current node
            local i = string.find(text, ":") or 0
            return string.sub(text, 1, i-1)
        end
    },
    qml = {
        type_patterns = { "ui_object_definition" }
    },
}

local function code_context()
    local opts = ft_opts[vim.bo.filetype] or {} -- else the defaults are good enough for now
    return require("nvim-treesitter").statusline(opts)
end

local function dap_status()
    return require('dap').status()
end

local function is_debugging()
    return dap_status() ~= ''
end

local function is_not_debugging()
    return not is_debugging()
end


return {
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            theme = 'jellybeansoverride'
        },
        extensions = { 'overseer', 'quickfix' },
        sections = {
            lualine_b = {
                { 'branch' },
                { 'diff', cond = is_not_debugging },
                { 'diagnostics', cond = is_not_debugging },
                { dap_status, cond = is_debugging }
            },
            lualine_c = {
                {
                    'filename',
                    path = 1
                }
            },
            lualine_x = { code_context }
        },
        inactive_sections = {
            lualine_c = {
                {
                    'filename',
                    path = 1
                }
            },
        }
    }
}
