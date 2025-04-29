local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local pwsh = { "pwsh.exe", "-NoLogo" }

config.color_scheme = 'Tomorrow Night right'
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

config.keys = {}

for i=1,9 do
    table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = act.ActivateTab(i-1), })
end

for k, v in pairs({ w = "Up", a = "Left", s = "Down", d = "Right" }) do
    table.insert(config.keys, { key = k, mods = 'ALT', action = act.ActivatePaneDirection(v), })
end

wezterm.on('dynamic-split', function(window, pane)
    local dims = pane:get_dimensions()
    local d
    local fraction = dims.cols / dims.viewport_rows
    if fraction > 3 then 
        d = "Right"
    else
        d = "Bottom"
    end
    pane:split{ direction = d }
end)
table.insert(config.keys, { key = "Enter", mods = "CTRL|SHIFT", action = act.EmitEvent('dynamic-split') })

wezterm.on('update-status', function(window, pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    { Attribute = { Underline = 'Single' } },
    { Attribute = { Italic = true } },
    { Text = date },
  })
end)

return config
