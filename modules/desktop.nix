{ config, pkgs, hy3Package, hyprlandPackage, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles/config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in

{
	wayland.windowManager.hyprland = {
		enable = true;
		package = hyprlandPackage;
		plugins = [ hy3Package ];
		settings = {
			monitor = ",preferred,auto,1.5";
			"$terminal" = "wezterm";
			"$fileManager" = "dolphin";
			"$menu" = "wofi --show drun";
			"exec-once" = [ "waybar" "hyprpaper" ];
			env = [
				"XCURSOR_SIZE,24"
				"HYPRCURSOR_SIZE,24"
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
	];
}
