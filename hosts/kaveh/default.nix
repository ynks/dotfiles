{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "kaveh";
  networking.wireless.enable = true;

  ##################################################
  # NVIDIA Optimus (AMD iGPU + NVIDIA dGPU)
  ##################################################

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ##################################################
  # ASUS ROG
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
  # Home-manager overrides
  ##################################################

  home-manager.users.xein = {
    home.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
}
