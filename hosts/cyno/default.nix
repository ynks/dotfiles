{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware.nix ./runners.nix ];

  networking.hostName = "cyno";

  ##################################################
  # NVIDIA Desktop
  ##################################################

  boot.loader.systemd-boot.configurationLimit = 1;
  boot.initrd.compressor = "xz -9";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
