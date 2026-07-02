{ config, pkgs, ... }:

{
  programs.plasma = {
    shortcuts = {
      "kwin"."Switch to Next Desktop" = "Ctrl+F1";
      "kwin"."Switch to Previous Desktop" = "Ctrl+F2";
      "kwin"."Expose" = "Ctrl+F3";
      "yakuake"."_launch" = "Meta+Return";
      "krunner"."_launch" = "Alt+Space";
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
    };
  };
}
