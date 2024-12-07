local function code_context()
    local opts = {}

    if vim.bo.filetype == "yaml" then
        opts.type_patterns = { "block_mapping_pair" }
        opts.transform_fn = function(text, node)
            -- Strip ":" from parent nodes and ": some value" or ": |" from the current node
            local i = string.find(text, ":") or 0
            return string.sub(text, 1, i-1)
        end
    elseif vim.bo.filetype == "qml" then
        opts.type_patterns = { "ui_object_definition" }
    end
    -- else the defaults are good enough for now

    return require("nvim-treesitter").statusline(opts)
end

return {
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            theme = 'jellybeans'
        },
        extensions = { 'quickfix' },
        sections = {
            lualine_c = {
                {
                    'filename',
                    path = 1
                }
            },
            lualine_x = { code_context }
        }
    }
}
