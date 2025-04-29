local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.font = wezterm.font('Ubuntu Mono')

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    require('windows').apply_to_config(config)
end

config.keys = {}

for i=1,9 do
    table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = act.ActivateTab(i - 1), })
end

for key, dir in pairs({ w = "Up", a = "Left", s = "Down", d = "Right" }) do
    table.insert(config.keys, { key = key, mods = 'ALT', action = act.ActivatePaneDirection(dir), })
end

table.insert(config.keys, {
    key = "Enter",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(_, pane)
        local dims = pane:get_dimensions()
        local fraction = dims.cols / dims.viewport_rows
        if fraction > 3 then
            pane:split{ direction = "Right" }
        else
            pane:split{ direction = "Bottom" }
        end
    end)
})

wezterm.on('update-status', function(window, _)
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    { Attribute = { Underline = 'Single' } },
    { Attribute = { Italic = true } },
    { Text = date },
  })
end)

return config
