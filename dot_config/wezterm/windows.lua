local wezterm = require 'wezterm'

-- This is the module table that we will export
local module = {}

-- define a function in the module table.
-- Only functions defined in `module` will be exported to
-- code that imports this module.
-- The suggested convention for making modules that update
-- the config is for them to export an `apply_to_config`
-- function that accepts the config object, like this:
function module.apply_to_config(config)
    local pwsh = { "pwsh.exe", "-NoLogo" }
    config.font = wezterm.font('Cascadia Mono')
    config.default_prog = pwsh
    config.launch_menu = {
        {
            label = 'Powershell Core',
            args = pwsh,
        },
        {
            label = 'Powershell Core VS 2022 x64',
            args = {
                'pwsh.exe', '-NoExit', '-Command',
                'Import-Module "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell 65797b13 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"'
            }
        },
        {
            label = 'Powershell Core VS 2019 x64',
            args = {
                'pwsh.exe', '-NoExit', '-Command',
                'Import-Module "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell 65797b13 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64 -vcvars_ver=14.29"'
            }
        },
        {
            label = 'MSYS2',
            args = {
                "C:/tools/msys64/msys2_shell.cmd", "-defterm", "-here", "-no-start", "-msys", "-shell", "zsh"
            }
        }
    }
end

-- return our module table
return module
