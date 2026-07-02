{ config, pkgs, ... }:

{
  programs.plasma = {
    configFile = {
      "kwinrc"."Desktops"."Number" = "4";
      "kwinrc"."Desktops"."Rows" = "1";
      "kwinrc"."Desktops"."Name_1" = "Main";
      "kwinrc"."Desktops"."Name_2" = "Dev";
      "kwinrc"."Desktops"."Name_3" = "Comms";
      "kwinrc"."Desktops"."Name_4" = "Media";
      "kwinrc"."Compositing"."Enabled" = true;
      "kwinrc"."Compositing"."OpenGLIsUnsafe" = false;
    };
  };
}
