{ config, lib, pkgs, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
	];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;

	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.graphics.enable = true;
	hardware.graphics.enable32Bit = true;

	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = true;
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};

	networking.hostName = "kaveh"; # Define your hostname

	networking.networkmanager.enable = true;
	networking.wireless.enable = true;

	# Set your time zone.
	time.timeZone = "Europe/Madrid";

	# services.getty.autologinUser = "xein"; # autologin
	services.displayManager.ly.enable = true; # use a login screen

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

