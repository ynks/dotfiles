{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # DAW
    reaper
    raysession
    carla
    qpwgraph

    # Mixing / mastering
    lsp-plugins
    x42-plugins

    # Synths
    surge-xt

    # VSTs
    yabridge
    yabridgectl
    wineWowPackages.staging
    winetricks
  ];
}
