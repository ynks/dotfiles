{ pkgs, ... }:

{
  imports = [
    ./modules/desktop
    ./modules/shell.nix
    ./modules/coding.nix
    ./modules/gaming.nix
    ./modules/art.nix
    ./modules/audio.nix
  ];

  home.username = "xein";
  home.homeDirectory = "/home/xein";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    discord
    onlyoffice-desktopeditors
    libreoffice
  ];
}
