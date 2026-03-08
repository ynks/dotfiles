{ config, lib, pkgs, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
	];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.kernelParams = [ 
		"nvidia-drm.modeset=1"
		"nvidia-drm.fbdev=1"
	];
	boot.initrd.kernelModules = [ "amdgpu" ];
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.graphics.enable = true;
	hardware.graphics.enable32Bit = true;
	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = true;
		open = true;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};

	systemd.services.supergfxd.path = [ pkgs.pciutils ];
	services.power-profiles-daemon.enable = true;
	services.upower.enable = true;
	services.supergfxd = {
		enable = true;
		settings = {
			no_logind = false;
			logout_timeout_s = 10;
		};
	};

	services.asusd.enable = true;

	networking.hostName = "kaveh"; # Define your hostname

	networking.networkmanager.enable = true;
	networking.wireless.enable = true;

	# Set your time zone.
	time.timeZone = "Europe/Madrid";

	# services.getty.autologinUser = "xein"; # autologin
	services.greetd = {
		enable = true;
		settings.default_session = {
			command = "Hyprland";
			user = "xein";
		};
	};
	# Enable touchpad support (enabled default in most desktopManager).
	services.libinput.enable = true;

	users.users.xein = {
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # Enable ‘sudo'
		packages = with pkgs; [
			tree
		];
	};

	programs.firefox.enable = true;
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		# withUWSM = true; # we dont want to use uwsm for now
	};
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
	};

	# List packages installed in system profile.
	environment.systemPackages = with pkgs; [
		vim
		wget
		wezterm
		waybar
		hyprpaper
		wofi

		macchina
		hyfetch
	];

	# Enable the OpenSSH daemon.
	services.openssh.enable = true;
	
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	system.stateVersion = "25.11"; # Do NOT change
}

