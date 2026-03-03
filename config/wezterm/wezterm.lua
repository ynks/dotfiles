local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.initial_cols = 90
config.initial_rows = 36
config.enable_tab_bar = false

config.font_size = 12
config.font = wezterm.font_with_fallback {
	"Monocraft",
	{ family = "JetBrainsMono Nerd Font", scale = 2 }
}
config.color_scheme = "tokyonight_night"

return config

