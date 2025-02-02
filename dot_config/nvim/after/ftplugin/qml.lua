local Path = require'plenary.path'

vim.opt.suffixesadd:append(".qml")
local buf_path = Path:new(vim.api.nvim_buf_get_name(0)):parent()

for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 1, 20, false)) do
    local _, _, capture = string.find(line, 'import "([^"]*)"')
    if capture ~= nil then
        local include_path
        if string.find(capture, "../") == 1 then
            include_path = buf_path:parent() / string.sub(capture, 4)
        else
            include_path = buf_path / Path:new(capture)
        end

        if include_path:is_dir() then
            vim.opt_local.path:prepend(include_path.filename)
        end
    end
end

vim.keymap.set('n', 'gd', 'gf', { buffer = true })
