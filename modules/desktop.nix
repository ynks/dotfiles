{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles/config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
	wallpaper = "${config.home.homeDirectory}/dotfiles/wallpapers/genshin-venti5.jpeg";
in {

dconf.settings = {
	"org/gnome/shell" = {
		disable-user-extensions = false;
		enabled-extensions = [
			"blur-my-shell@aunetx"
		];
	};

	# Blur My Shell settings
	"org/gnome/shell/extensions/blur-my-shell" = {
		blur-applications = false;
		blur-overview = true;
		brightness = 0.6;
	};

	# Colorscheme
	"org/gnome/desktop/interface" = {
		color-scheme = "prefer-dark";
		enable-hot-corners = false;
		gtk-application-prefer-dark-theme = true;
	};

	# Wallpaper
	"org/gnome/desktop/background" = {
		picture-uri = "file://${wallpaper}";
		picture-uri-dark = "file://${wallpaper}";
	};

	# Lock screen
	"org/gnome/desktop/screensaver" = {
		picture-uri = "file://${wallpaper}";
	};
};

# Home packages
home.packages = with pkgs; [
	gnome-shell-extensions
	gnomeExtensions.blur-my-shell
	gnome-tweaks

	# Terminal & utilities
	wezterm
	jq
	brightnessctl

	# Screenshot
	gnome-screenshot
	satty

	# Fonts
	monocraft
	nerd-fonts.jetbrains-mono

	# Cursor theme
	rose-pine-cursor
];

# Wezterm configuration with not-modern taskbar
xdg.configFile = {
	wezterm = { source = create_symlink "${dotfiles}/wezterm"; recursive = true; };
};

}
