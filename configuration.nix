{ config, lib, pkgs, ... }:

{
	imports = [ # Hardware scan results
		./hardware-configuration.nix
	];

##################################################
# Boot
##################################################

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.kernelParams = [ # NVIDIA DRM for Wayland
		"nvidia-drm.modeset=1"
		"nvidia-drm.fbdev=1"
	];

	# iGPU module needed for hybrid graphics laptops
	boot.initrd.kernelModules = [ "amdgpu" ];

##################################################
# Graphics (NVIDIA + AMD integrated GPU)
##################################################

	services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};

	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = true;
		open = true; # Use open kernel modules
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};

##################################################
# ASUS / Hybrid GPU management
##################################################

	systemd.services.supergfxd.path = [ pkgs.pciutils ];

	services.supergfxd = {
		enable = true;
		settings = {
			no_logind = false;
			logout_timeout_s = 10;
		};
	};

	services.asusd.enable = true;
	services.power-profiles-daemon.enable = true;
	services.upower.enable = true;

##################################################
# Networking
##################################################

	networking.hostName = "kaveh";

	networking.networkmanager.enable = true;
	networking.wireless.enable = true;

##################################################
# Time / Locale
##################################################

	time.timeZone = "Europe/Madrid";

##################################################
# Login manager
##################################################

	# WARN: IF YOU ARE NOT XEIN
	# Ly does not work well with asusd and supergfxd
	# Do not use ly as it's incompatible with logind and will not
	# switch your graphic card settings
	services.greetd = {
		enable = true;
		settings.default_session = {
			command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd start-hyprland";
			user = "greeter";
		};
	};

##################################################
# Input
##################################################

	services.libinput.enable = true;

##################################################
# Users
##################################################

	users.users.xein = {
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # sudo access
		packages = with pkgs; [
			tree
		];
	};

##################################################
# Programs
##################################################

	programs.firefox.enable = true;

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
	};

##################################################
# System packages
##################################################

	environment.systemPackages = with pkgs; [
		vim
		wget

# terminal / UI
		wezterm
		waybar
		hyprpaper
		wofi

# system info
		macchina
		hyfetch # pride flag neofetch
	];

##################################################
# Services
##################################################

	services.openssh.enable = true;

##################################################
# Nix package manager config
##################################################

	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [
		"nix-command"
		"flakes"
	];

##################################################
# System version (DO NOT change even if you update)
##################################################

	system.stateVersion = "25.11";
}
