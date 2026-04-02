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
			"appindicatorsupport@rgcjonas.gmail.com"
		];
	};

	# Blur My Shell settings
	"org/gnome/shell/extensions/blur-my-shell" = {
		blur-applications = false;
		blur-overview = true;
		brightness = 0.6;
	};

	# Colorscheme & Interface
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

	# Fractional scaling
	"org/gnome/desktop/display" = {
		scale-monitor-1 = 1.5;
	};
};

# Home packages
home.packages = with pkgs; [
	gnome-shell-extensions
	gnomeExtensions.blur-my-shell
	gnomeExtensions.appindicator
	gnome-tweaks
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

	# Browser
	firefox
];

# Wezterm configuration with not-modern taskbar
xdg.configFile = {
	wezterm = { source = create_symlink "${dotfiles}/wezterm"; recursive = true; };
};

# User directories configuration
xdg.userDirs = {
	desktop = null;
	documents = null;
	download = "${config.home.homeDirectory}/downloads";
	music = null;
	pictures = null;
	publicShare = null;
	templates = null;
	videos = null;
};

# Session variables for default editor
home.sessionVariables = {
	EDITOR = "nvim";
};

programs.firefox = {
	enable = true;
	profiles.default = {
		settings = {
			"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
			"browser.uidensity" = 1;
		};
		userChrome = ''
			/* Firefox GNOME theme integration */
			:root {
				--arrowpanel-border-color: rgba(0,0,0,.2);
				--arrowpanel-background: #fff;
				--lwt-toolbarbutton-hover-background: rgba(0,0,0,.06);
			}
		'';
	};
};

}
