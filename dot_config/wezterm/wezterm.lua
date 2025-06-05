local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.font = wezterm.font('Deja Vu Sans Mono')
config.font_size = 11.5
config.freetype_load_target = "Light"

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    require('windows').apply_to_config(config)
end

config.audible_bell = "Disabled"

-- Use Kitty's exact colors for now. Taken from Kitty's home page
config.colors = {
    foreground = '#eeeeee',
    background = 'black',
    ansi = {
        '#000000',
        '#cc0403',
        '#19cb00',
        '#cecb00',
        '#0d73cc',
        '#cb1ed1',
        '#0dcdcd',
        '#dddddd',
    },
    brights = {
        '#767676',
        '#f2201f',
        '#23fd00',
        '#fffd00',
        '#1a8fff',
        '#fd28ff',
        '#14ffff',
        '#ffffff',
    },
    cursor_bg = "#eeeeee"
}
config.bold_brightens_ansi_colors = false

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

for key, dir in pairs({ UpArrow = -1, DownArrow = 1 }) do
    table.insert(config.keys, { key = key, mods = 'SHIFT', action = act.ScrollToPrompt(dir) })
end

config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor('SemanticZone'),
    mods = 'NONE',
  },
}

wezterm.on('update-status', function(window, _)
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    { Attribute = { Underline = 'Single' } },
    { Attribute = { Italic = true } },
    { Text = date },
  })
end)

config.ssh_domains = {
  {
    -- This name identifies the domain
    name = 'work-desktop',
    -- The hostname or address to connect to. Will be used to match settings
    -- from your ssh config file
    remote_address = 'oystein-w-KomplettPC',
    -- The username to use on the remote host
    username = 'oystein-w',
  },
}

config.unix_domains = {
  {
    name = 'unix',
  },
}

config.default_gui_startup_args = { 'connect', 'unix' }

return config
