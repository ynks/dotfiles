{ config, pkgs, plasma-manager, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in

{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; with kdePackages; [
    konsole
    yakuake
    dolphin
    kate
    krename
    kfind
    filelight
    kdf
    partitionmanager
    ksystemlog
    ktimer
    sweeper
    isoimagewriter
    elisa
    haruna
    krecorder
    audiotube
    plasmatube
    gwenview
    spectacle
    kcolorchooser
    kcalc
    kontact
    kmail
    korganizer
    akregator
    kteatime
    ghostwriter
    kleopatra
    kompare
    ktorrent
    kget
    kweather
    kstars
    kile
    skanlite
    skanpage
    kclock
    kpat
    kmousetool
    kcachegrind
    kmines
    kmag
    kmahjongg
    kmix
    knights
    umbrello
    ktrip
    francis
    kalgebra
    kmplot
    kig
    kalzium
    cantor
    step
    rocs
    labplot
  ];
}
