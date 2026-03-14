{ config, pkgs, hy3Package, hyprlandPackage, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles/config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in {
	wayland.windowManager.hyprland = {
		enable = true;
		package = hyprlandPackage;
		plugins = [ hy3Package ];
		settings = {
			monitor = [ 
				"eDP-1,preferred,auto,1.5"
				"HDMI-A-1,preferred,auto,1,mirror,eDP-1"
			];
			"$terminal" = "wezterm";
			"$fileManager" = "dolphin";
			"$menu" = "wofi --show drun";
			"exec-once" = [ "hyprpaper" "hyprctl setcursor rose-pine-hyprcursor 24" "waybar" ];
			env = [
				"XCURSOR_SIZE,24"
				"HYPRCURSOR_SIZE,24"
				"HYPRCURSOR_THEME,rose-pine-hyprcursor"
				"XCURSOR_THEME,rose-pine-cursor"
			];
			source = [
				"/home/xein/dotfiles/config/hypr/behaviour.conf"
				"/home/xein/dotfiles/config/hypr/input.conf"
				"/home/xein/dotfiles/config/hypr/binds.conf"
				"/home/xein/dotfiles/config/hypr/rules.conf"
			];
		};
	};

	xdg.configFile = {
		# hyprpaper
		"hypr/hyprpaper.conf".text = ''
			wallpaper {
				monitor = 
				path = ~/dotfiles/wallpapers/genshin-venti5.jpeg
				fit_mode = cover
			}

			splash = false
		'';

		# wezterm + waybar (managed externally)
		wezterm = { source = create_symlink "${dotfiles}/wezterm"; recursive = true; };
		waybar = { source = create_symlink "${dotfiles}/waybar"; recursive = true; };

		# macchina
		"macchina/macchina.toml".text = ''
			long_uptime = true
			long_shell = false
			memory_percentage = true
			theme = "custom"

			show = [
				"Host",
				"Machine",
				"Kernel",
				"Distribution",
				"DesktopEnvironment",
				"Packages",
				"Shell",
				"Terminal",
				"Uptime",
				"Processor",
				"Memory",
				"GPU"
			]
		'';

		"macchina/themes/custom.toml".text = ''
			hide_ascii = true
			spacing = 2
			separator = " ›"

			[palette]
			type = "Full"
			visible = true

			[keys]
			distribution = "Distro"
			processor = "CPU"
			memory = "RAM"
		'';

		# hyfetch
		"hyfetch.json".text = builtins.toJSON {
			preset = "nonbinary";
			mode = "rgb";
			auto_detect_light_dark = true;
			light_dark = "dark";
			lightness = 0.65;
			color_align = { mode = "horizontal"; };
			backend = "macchina";
			args = null;
			distro = null;
			pride_month_disable = false;
			custom_ascii_path = "/home/xein/dotfiles/config/nix-logo.render";
		};
	};

	home.packages = with pkgs; [
		wezterm
		waybar
		hyprpaper
		wofi
		jq
		brightnessctl

		# screenshot
		grim
		slurp
		satty

		# fonts
		monocraft
		nerd-fonts.jetbrains-mono

		# cursor
		rose-pine-hyprcursor
		rose-pine-cursor
	];

	services.dunst = {
		enable = true;
		settings = {
			global = {
				width = 350;
				offset = "(5, 5)";
				origin = "bottom-right";

				progress_bar_min_width = 330;
				progress_bar_max_width = 330;
				progress_bar_corner_radius = 2;

				padding = 10;
				horizontal_padding = 10;
				frame_width = 2;
				gap_size = 3;
				font = "Monocraft 12";

				corner_radius = 1;
				background = "#16161e";
				foreground = "#e0def4";
			};

			urgency_low = {
				background = "#16161e";
				highlight = "#7dcfff";
				frame_color = "#7dcfff";
				format = "<b>%s</b>\\n%b";
			};

			urgency_normal = {
				background = "#16161e";
				highlight = "#ff9e64";
				frame_color = "#ff9e64";
				format = "<b>%s</b>\\n%b";
			};

			urgency_critical = {
				background = "#f7768e";
				highlight = "#16161e";
				foreground = "#16161e";
				frame_color = "#f7768e";
				format = "<b>%s</b>\\n%b";
			};
		};
	};

	home.pointerCursor = {
		gtk.enable = true;
		x11.enable = true;
		package = pkgs.rose-pine-cursor;
		name = "rose-pine-cursor";
		size = 24;
	};
}
