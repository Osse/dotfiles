local function cmake_target_type(target_name)
    local ok, cm = pcall(require, 'cmake-tools')
    if not ok then return nil end
    local build_dir = tostring(cm.get_build_directory())
    if build_dir == '' or build_dir == 'nil' then return nil end
    local reply_dir = build_dir .. '/.cmake/api/v1/reply'
    local files = vim.fn.glob(reply_dir .. '/codemodel-v2-*.json', false, true)
    if #files == 0 then return nil end
    local ok2, codemodel = pcall(function()
        return vim.fn.json_decode(table.concat(vim.fn.readfile(files[1]), '\n'))
    end)
    if not ok2 or not codemodel then return nil end
    for _, cfg in ipairs(codemodel.configurations or {}) do
        for _, t in ipairs(cfg.targets or {}) do
            if t.name == target_name then
                local ok3, tdata = pcall(function()
                    return vim.fn.json_decode(table.concat(vim.fn.readfile(reply_dir .. '/' .. t.jsonFile), '\n'))
                end)
                if ok3 and tdata then return tdata.type end
            end
        end
    end
    return nil
end

local function select_and_sync_build_target()
    local cm = require('cmake-tools')
    local orig = vim.ui.select
    vim.ui.select = function(items, opts, on_choice)
        vim.ui.select = orig
        orig(items, opts, function(choice, idx)
            if on_choice then on_choice(choice, idx) end
            if not choice then return end
            vim.schedule(function()
                local name = type(choice) == 'table' and (choice.name or choice[1]) or choice
                if not name then return end
                local ttype = (type(choice) == 'table' and choice.type) or cmake_target_type(name)
                if ttype ~= 'EXECUTABLE' then return end
                local orig2 = vim.ui.select
                vim.ui.select = function(litems, lopts, lon_choice)
                    vim.ui.select = orig2
                    for i, item in ipairs(litems) do
                        local iname = type(item) == 'table' and (item.name or item[1]) or item
                        if iname == name then
                            if lon_choice then lon_choice(item, i) end
                            return
                        end
                    end
                    orig2(litems, lopts, lon_choice)
                end
                cm.select_launch_target()
            end)
        end)
    end
    cm.select_build_target()
end

local function on_new_task(task)
    local o = require("overseer")

    task:subscribe("on_complete", function(t, result)
        if result == "SUCCESS" or result == "CANCELED" then
            o.close()
            vim.cmd("cclose")
        end
    end)

    vim.cmd("cclose")
    o.open( { enter = false, focus_task_id = task.id })
end

local function get_launch_args()
    local args = require('cmake-tools').get_launch_args()
    vim.print(args)
end

return {
    'Civitasv/cmake-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        cmake_generate_options = {},
        cmake_regenerate_on_save = false,
        cmake_executor = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    if task.name:find("--build") then
                        local t = cm.get_build_target()
                        if t and t[1] then
                            task.name = "Build " .. t[1]
                        else
                            task.name = "Build default"
                        end
                    end
                    on_new_task(task)
                end,
                new_task_opts = {
                    strategy = {
                        "jobstart"
                    },
                }
            },
        },
        cmake_runner = {
            name = "overseer",
            opts = {
                on_new_task = function(task)
                    local cm = require('cmake-tools')
                    task.name = "Run " .. (cm.get_launch_target() or "default") .. " " .. table.concat(cm.get_launch_args(), " ")
                    task.cwd = vim.fn.getcwd()
                    on_new_task(task)
                end,
                new_task_opts = {
                    strategy = {
                        "jobstart"
                    },
                }
            },
        },
        cmake_virtual_text_support = false,
        cmake_dap_configuration = {
            type = "gdb",
        }
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "CMakeToolsEnterProject",
            group = vim.api.nvim_create_augroup("minvimrc", { clear = true }),
            callback = function(_)
                local cm = require('cmake-tools')
                vim.keymap.set('n', '<F4>', select_and_sync_build_target)
                vim.keymap.set('n', '<F5>', function() cm.build({}) end)
                vim.keymap.set('n', '<F6>', function() cm.run({}) end)
                vim.keymap.set('n', '<F7>', function() cm.build_current_file({}) end)
                vim.keymap.set('n', '<F18>', function() cm.stop_executor({}) end)
                vim.keymap.set('n', '<S-F6>', function() cm.stop_executor({}) end)
            end
        })
        vim.api.nvim_create_user_command(
            "CMakeGetLaunchArgs",
            get_launch_args,
            { -- opts
                nargs = 0,
                desc = "CMake Get Launch args",
            }
        )
    end
}
