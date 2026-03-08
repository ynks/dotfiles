{ config, pkgs, ... }:

let
	# dotfiles stuff
	dotfiles = "${config.home.homeDirectory}/dotfiles/config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
	configs = {
		nvim = "nvim";
		hypr = "hypr";
		wezterm = "wezterm";
		waybar = "waybar";
		macchina = "macchina";
	};
in

{
	home.username = "xein";
	home.homeDirectory = "/home/xein";
	home.stateVersion = "25.11";

	home.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		WLR_NO_HARDWARE_CURSORS = "1";
		LIBVA_DRIVER_NAME = "nvidia";
		XDG_SESSION_TYPE = "wayland";
		GBM_BACKEND = "nvidia-drm";
		__GLX_VENDOR_LIBRARY_NAME = "nvidia";
	};

	programs.bash = {
		enable = true;
		shellAliases = {
			n = "nvim";
			x = "xmake";
			g = "git";
			fetch = "MACCHINA_THEME=custom hyfetch";
		};
		profileExtra = ''
			if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
				exec start-hyprland
			fi
		'';
	};

	programs.git = {
		enable = true;
		lfs.enable = true;

		settings = {
			user.name = "Xein";
			user.email = "xgonip@gmail.com";
			core.editor = "nvim";
			init.defaultBranch = "main";
			push.autoSetupRemote = true;
		};
	};

	# create dotfiles symlinks
	xdg.configFile = builtins.mapAttrs (name: subpath: {
		source = create_symlink "${dotfiles}/${subpath}";
		recursive = true;
	}) configs;

	# packages
	home.packages = with pkgs; [
		# fonts
		monocraft
		nerd-fonts.jetbrains-mono

		# ToastVim config
		neovim
		lua
		lua55Packages.luarocks_bootstrap
		lazygit
		fd
		ripgrep
		fzf
		nodejs_25
		curl
		tree-sitter
		tectonic
		ghostscript

		# programming tools
		# gcc
		gnumake
		cmake
		xmake
		rustup
		llvmPackages_latest.clang
		llvmPackages_latest.llvm
		llvmPackages_latest.lldb
		clang-tools
		dotnetCorePackages.sdk_10_0
		roslyn-ls
		nixd
		emmylua-ls

		# steam stuff
		protonup-qt
		mangohud
		gamescope
	];
}
