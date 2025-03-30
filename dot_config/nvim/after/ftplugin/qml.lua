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

local function mysplit(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^.]+)") do
    table.insert(t, str)
  end
  return t
end

local function find_id(w)
    return vim.fn.search("^\\s*\\<id:\\s*\\zs" .. w .. "\\>")
end

local function goto_definition()
    local w = vim.fn.expand('<cword>')

    local ret = find_id(w)

    if ret == 0 then
        local t = mysplit(vim.fn.expand('<cWORD>'))
        if #t > 1 then
            if find_id(t[1]) ~= 0 then
                vim.fn.search("^\\s*property.*\\zs\\<" .. t[2] .. "\\>")
            end
        else
            vim.cmd("normal! gf")
        end
    end
end

vim.keymap.set('n', 'gd', goto_definition, { buffer = true })
