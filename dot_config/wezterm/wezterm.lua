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

-- Same as tmux but allow tmux
config.leader = { key = 'b', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }

config.keys = {}
local function bind(k)
    table.insert(config.keys, k)
end

bind({
    key = 'a',
    mods = 'LEADER',
    action = act.AttachDomain('unix'),
})

bind({
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain('CurrentPaneDomain'),
})

for i=1,9 do
    bind({ key = tostring(i), mods = 'ALT', action = act.ActivateTab(i - 1), })
end

for key, dir in pairs({ w = "Up", a = "Left", s = "Down", d = "Right" }) do
    bind({ key = key, mods = 'ALT', action = act.ActivatePaneDirection(dir), })
end

bind({
    key = 't',
    mods = 'LEADER',
    action = act.SpawnTab('DefaultDomain')
})

bind({
    key = "Enter",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(_, pane)
        local dims = pane:get_dimensions()
        local fraction = dims.cols / dims.viewport_rows
        if fraction > 3 then
            pane:split{ direction = "Right", domain = "CurrentPaneDomain" }
        else
            pane:split{ direction = "Bottom", domain = "CurrentPaneDomain" }
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

table.insert(config.keys, {
    key = 'a',
    mods = 'LEADER',
    action = act.AttachDomain 'unix',
  }
)

table.insert(config.keys, {
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain { DomainName = 'unix' },
})

config.ssh_domains = {
    {
        name = 'work-desktop',
        remote_address = 'work-deskop',
    },
}

config.unix_domains = {
    {
        name = 'unix',
    },
    {
        name = 'unixwork',
        proxy_command = { "ssh", "-T", "work-desktop", "wezterm", "cli", "proxy" },
    },
}

-- config.default_gui_startup_args = { 'connect', 'unix' }

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

local tab_bg_colors = {
    ["local"] = {
        [true] = wezterm.color.parse('black'),
        [false] = wezterm.color.parse('#333333')
    },
    ["unix"] = {
        [true] = wezterm.color.parse('#33520B'),
        [false] = wezterm.color.parse('#33520B'):desaturate(0.5)
    },
    ["unixwork"] = {
        [true] = wezterm.color.parse('#8E3B46'),
        [false] = wezterm.color.parse('#8E3B46'):desaturate(0.5)
    },
}

local tab_fg_colors = {
    [true] = wezterm.color.parse('#c0c0c0'),
    [false] = wezterm.color.parse('#808080')
}

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab)
    local pane = tab.active_pane
    local bg_color = tab_bg_colors[pane.domain_name][tab.is_active]
    local fg_color = tab_fg_colors[tab.is_active]

    local format = {
        { Background = { Color = bg_color } },
        { Foreground = { Color = fg_color } },
        { Text = title },
        { Text = " (" .. pane.domain_name .. ")" },
    }
    return format
  end
)

return config
