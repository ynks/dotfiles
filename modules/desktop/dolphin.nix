{ config, pkgs, ... }:

{
  programs.plasma = {
    configFile = {
      "dolphinrc"."General"."ShowFullPath" = true;
      "dolphinrc"."General"."ShowSpaceInfo" = false;
      "dolphinrc"."KPropertiesDialog"."AltDir" = true;
      "dolphinrc"."PreviewSettings"."Plugins" = "textfiles,images,archives,audiothumbnail,videothumbnail,svg";
      "dolphinrc"."DetailsMode"."Previews" = true;
    };
  };
}
