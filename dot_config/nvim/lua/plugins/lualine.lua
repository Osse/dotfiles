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

local cmake = require("cmake-tools")

local function run(cmd)
    return function(n, mouse)
       if n == 1 and mouse == "l" then
           -- Feed through the input queue so it runs *after* the pending mouse
           -- release; otherwise fzf-lua's `startinsert` gets clobbered and the
           -- picker opens in normal mode.
           vim.api.nvim_feedkeys(":" .. cmd .. "\r", "n", false)
       end
   end
end

local function combine(s1, s2)
    local s = (s1 and s1[1] or "X")
    if s2 and s2 ~= s1[1] then
        s = s .. "/" .. s2
    end
    return s
end

local icons = require('icons')

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
                { dap_status, cond = is_debugging },
            },
            lualine_x = {
                {
                  function()
                    return vim.fs.relpath(vim.fn.getcwd(),cmake.get_config().cwd)
                  end,
                  icon = require'nvim-web-devicons'.get_icon_by_filetype("cmake"),
                  separator = '',
                  cond = cmake.is_cmake_project,
                  on_click = run("CMakeSelectConfigurePreset")
                },
                {
                  function()
                    local c_preset = cmake.get_configure_preset()
                    local b_preset = cmake.get_build_preset()
                    return combine({c_preset}, b_preset)
                  end,
                  icon = "",
                  separator = '',
                  cond = function()
                    return cmake.is_cmake_project() and cmake.has_cmake_preset()
                  end,
                  on_click = run("CMakeSelectConfigurePreset")
                },
                {
                  function()
                    local b_target = cmake.get_build_target()
                    local l_target = cmake.get_launch_target()
                    return combine(b_target, l_target)
                  end,
                  separator = '',
                  icon = "󰓾",
                  cond = cmake.is_cmake_project,
                  on_click = run("CMakeSelectBuildTarget")
                },
                {
                  function() return icons.ui.Gear end,
                  separator = '',
                  cond = cmake.is_cmake_project,
                  on_click = run("CMakeBuild")
                },
                {
                  function() return icons.ui.Run end,
                  separator = '',
                  cond = cmake.is_cmake_project,
                  on_click = run("CMakeRun")
                },
                {
                  function() return icons.ui.Debug .. " " end,
                  separator = '',
                  cond = cmake.is_cmake_project,
                  on_click = run("CMakeDebug")
                },
            },
            lualine_c = {
                {
                    'filename',
                    path = 1
                }
            },
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
