{ config, pkgs, ... }:

{
  programs.plasma = {
    configFile = {
      "kdeglobals"."KDE"."ColorScheme" = "BreezeDark";
      "kdeglobals"."General"."ColorScheme" = "BreezeDark";
      "plasmarc"."Theme"."name" = "breeze-dark";
      "kwinrc"."org.kde.kdecoration2"."theme" = "Breeze";
      "gtk-3.0/settings.ini"."Settings"."gtk-theme-name" = "Breeze";
      "gtk-3.0/settings.ini"."Settings"."gtk-application-prefer-dark-theme" = true;
      "gtk-4.0/settings.ini"."Settings"."gtk-theme-name" = "Breeze";
      "gtk-4.0/settings.ini"."Settings"."gtk-application-prefer-dark-theme" = true;
    };
  };

  home.packages = with pkgs; [
    # Cursor
    rose-pine-cursor
    # Fonts
    monocraft
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  home.sessionVariables = {
    GTK_THEME = "Breeze:dark";
  };
}
