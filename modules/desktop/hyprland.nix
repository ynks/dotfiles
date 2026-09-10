{ config, pkgs, inputs, ... }:
let
  dotfilesRoot = "${config.home.homeDirectory}/Code/dotfiles";
  dotfiles = "${dotfilesRoot}/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # execs.lua execs the agent by the bare Arch path; give it a PATH-resolvable
  # name instead (same wrapper trick the old niri.nix used).
  polkit-kde-agent = pkgs.writeShellScriptBin "polkit-kde-authentication-agent-1" ''
    exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1 "$@"
  '';
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  # Upstream dots, read-only out of the flake input. recursive = true is load-bearing:
  # hyprland.lua does maybe_copy(scheme/default.lua -> scheme/current.lua) on first
  # start and `caelestia scheme set` rewrites it, so ~/.config/hypr/scheme/ has to be
  # a real writable directory rather than one symlink to the whole store tree.
  xdg.configFile.hypr = {
    source = "${inputs.caelestia-dots}/hypr";
    recursive = true;
  };

  # hyprland.lua puts ~/.config/caelestia on package.path, then requires "hypr-vars"
  # (variable overrides) and, last in the load order, "hypr-user" (free-form config).
  # Out-of-store so they're editable without a rebuild, like config/nvim.
  xdg.configFile."caelestia/hypr-vars.lua".source =
    create_symlink "${dotfiles}/caelestia/hypr-vars.lua";
  xdg.configFile."caelestia/hypr-user.lua".source =
    create_symlink "${dotfiles}/caelestia/hypr-user.lua";

  programs.caelestia = {
    enable = true;
    cli.enable = true;
    # execs.lua already runs `caelestia shell -d` from the hyprland.start hook.
    # Leaving the HM systemd service on would start a second copy.
    systemd.enable = false;
    # Deliberately no `settings`/`cli.settings`: the HM module would then write
    # ~/.config/caelestia/shell.json as a read-only store symlink and the shell's
    # own settings UI could no longer save. Defaults already match what we want
    # (wallpaperDir = ~/Pictures/Wallpapers).
  };

  home.file."Pictures/Wallpapers/genshin-xiao.jpg".source =
    create_symlink "${dotfilesRoot}/wallpapers/genshin-xiao.jpg";

  home.packages = with pkgs; [
    polkit-kde-agent
    gnome-keyring # execs.lua: gnome-keyring-daemon --start
    cliphist
    wl-clipboard
    trash-cli # execs.lua: trash-empty 30
    glib # execs.lua: gsettings
    gammastep
    bluez # execs.lua: mpris-proxy
    grim
    slurp
    swappy # caelestia-cli screenshot/record path
    libnotify
    brightnessctl
    ddcutil
    xdg-utils
  ];
}
