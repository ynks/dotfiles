{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  ##################################################
  # Boot
  ##################################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ##################################################
  # Networking
  ##################################################

  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 1701 9001 ];

  ##################################################
  # Time & Locale
  ##################################################

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  ##################################################
  # X11 / KDE Plasma
  ##################################################

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "caps:super";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  ##################################################
  # Graphics / NVIDIA (shared defaults)
  ##################################################

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ##################################################
  # Audio
  ##################################################

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = [
        { name = "link.max-buffers"; value = 16; }
      ];
    };
  };

  ##################################################
  # Input
  ##################################################

  services.libinput.enable = true;

  ##################################################
  # Programs
  ##################################################

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.kdeconnect.enable = true;
  programs.nix-ld.enable = true;

  programs.weylus = {
  enable = true;
  openFirewall = true; # Automatically handles ports 1701 and 9001
  users = [ "xein" ]; # Replaces manual uinput group rules
};

xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
};

  ##################################################
  # Services
  ##################################################

  services.openssh.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;

  ##################################################
  # Users
  ##################################################

  users.users.xein = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "networkmanager" ];
  };

  ##################################################
  # System packages
  ##################################################

  environment.systemPackages = with pkgs; [
    vim
    wget
    macchina
    hyfetch
    nerd-fonts.fira-code
  ];

  ##################################################
  # Nix package manager config
  ##################################################

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      raysession = prev.raysession.override {
        python3Packages = prev.python312Packages;
      };
    })
  ];

  ##################################################
  # Flake update timer
  ##################################################

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
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /home/xein/dotfiles#$(hostname)
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
  # System version
  ##################################################

  system.stateVersion = "25.11";
}
