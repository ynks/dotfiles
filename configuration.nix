{ config, lib, pkgs, hyprland, system, ... }:

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
			hotplug_type = "Asus";
		};
	};

	services.asusd.enable = true;
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
			command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
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
		shell = pkgs.zsh;
		extraGroups = [ "wheel" "video" ];
		packages = with pkgs; [
			tree
		];
	};

##################################################
# Programs
##################################################

	programs.firefox.enable = true;
	programs.zsh.enable = true;

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		package = hyprland.packages.${system}.hyprland;
		portalPackage = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
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

# system info
		macchina
		hyfetch
	];

##################################################
# Services
##################################################

	services.openssh.enable = true;

	# services.ollama = {
	# 	enable = true;
	# 	package = pkgs.ollama-cuda;
	# };

	# Weekly flake update + rebuild
	systemd.services.flake-update = {
		description = "Update flake inputs and rebuild NixOS";
		serviceConfig = {
			Type = "oneshot";
			WorkingDirectory = "/home/xein/dotfiles";
			Nice = 19;
			IOSchedulingClass = "idle";
			ExecStart = "${pkgs.writeShellScript "flake-update" ''
				set -e
				${pkgs.nix}/bin/nix flake update --flake /home/xein/dotfiles
				${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /home/xein/dotfiles#kaveh
			''}";
		};
		unitConfig.ConditionACPower = true;
	};

	systemd.timers.flake-update = {
		description = "Weekly flake update";
		wantedBy = [ "timers.target" ];
		timerConfig = {
			OnCalendar = "weekly";
			Persistent = true;
			RandomizedDelaySec = "2h";
		};
		unitConfig.ConditionPathExists = "!/run/user/1000";
	};

##################################################
# Nix package manager config
##################################################

	nixpkgs.config.allowUnfree = true;
	nix.settings = {
		experimental-features = [
			"nix-command"
			"flakes"
		];
	};

##################################################
# System version (DO NOT change even if you update)
##################################################

	system.stateVersion = "25.11";
}
