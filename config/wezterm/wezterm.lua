local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 36
config.window_padding = {
	left = 0, right = 0, top = 0, bottom = 0
}

-- Enable tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.window_decorations = "TITLE | RESIZE"
config.tab_max_width = 120

config.font_size = 12
config.font = wezterm.font_with_fallback {
	"Monocraft",
	{ family = "JetBrainsMono Nerd Font", scale = 2 }
}
config.color_scheme = "tokyonight_night"

-- Custom tab bar with leader key indicator
wezterm.on("update-status", function(window, pane)
	local leader = ""
	if window:leader_is_active() then
		leader = "[LEADER] "
	end
	window:set_left_status(leader)
end)


-- Multiplexing shortcuts
config.leader = { key = "w", mods = "SUPER", timeout_milliseconds = 2000 }
config.keys = {
	-- Create tabs
	{ key = "t", mods = "LEADER", action = wezterm.action.SpawnTab "CurrentPaneDomain" },

	-- Tab navigation
	{ key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = wezterm.action.ActivateTab(8) },
	{ key = "0", mods = "ALT", action = wezterm.action.ActivateTab(9) },

	{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

	-- Show tab list
	{ key = "q", mods = "LEADER", action = wezterm.action.ShowTabNavigator },

	-- Split panes
	{ key = "b", mods = "LEADER", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 50 } } },
	{ key = "v", mods = "LEADER", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 50 } } },

	-- Navigate panes
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Left" },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Down" },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Up" },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Right" },

	-- Close panes/tabs
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane { confirm = true } },
	{ key = "w", mods = "LEADER", action = wezterm.action.CloseCurrentTab { confirm = true } },

	-- Resize panes
	{ key = "=", mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
	{ key = "-", mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
	{ key = ">", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
	{ key = "<", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize { "Left", 5 } },

	-- Zoom pane
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
}

return config


