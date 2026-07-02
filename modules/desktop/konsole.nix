{ config, pkgs, ... }:

{
  programs.plasma = {
    configFile = {
      "konsolerc"."KonsoleWindow"."DefaultSize" = "90x30";
    };
  };

  home.file = {
    ".local/share/konsole/GitHubDark.colorscheme" = {
      text = ''
        [Background]
        Color=13,17,23

        [BackgroundFaint]
        Color=13,17,23

        [BackgroundIntense]
        Color=13,17,23

        [Foreground]
        Color=230,237,243

        [ForegroundFaint]
        Color=139,148,158

        [ForegroundIntense]
        Color=230,237,243

        [Color0]
        Color=48,54,61

        [Color0Faint]
        Color=48,54,61

        [Color0Intense]
        Color=110,118,129

        [Color1]
        Color=255,123,114

        [Color1Faint]
        Color=255,123,114

        [Color1Intense]
        Color=255,123,114

        [Color2]
        Color=63,185,80

        [Color2Faint]
        Color=63,185,80

        [Color2Intense]
        Color=63,185,80

        [Color3]
        Color=210,153,34

        [Color3Faint]
        Color=210,153,34

        [Color3Intense]
        Color=210,153,34

        [Color4]
        Color=88,166,255

        [Color4Faint]
        Color=88,166,255

        [Color4Intense]
        Color=88,166,255

        [Color5]
        Color=197,117,225

        [Color5Faint]
        Color=197,117,225

        [Color5Intense]
        Color=197,117,225

        [Color6]
        Color=86,182,194

        [Color6Faint]
        Color=86,182,194

        [Color6Intense]
        Color=86,182,194

        [Color7]
        Color=230,237,243

        [Color7Faint]
        Color=230,237,243

        [Color7Intense]
        Color=230,237,243

        [General]
        Description=GitHub Dark
        Wallpaper=
        Opacity=1
      '';
    };

    ".local/share/konsole/Default.profile" = {
      text = ''
        [Appearance]
        ColorScheme=GitHubDark
        Font=Fira Code,11,-1,5,50,0,0,0,0,0,Regular
        AntiAliasing=Antialiasing
        BoldIntense=true

        [General]
        Name=Default
        Parent=FALLBACK/

        [Scrolling]
        HistoryMode=2
        HistorySize=8000

        [TerminalFeatures]
        BlinkingCursorEnabled=true
        UseShape=1

        [Interaction]
        AutoCopySelectedText=true
        TrimLeadingSpacesInSelectedText=true
        TextCursorCursorShape=2
      '';
    };
  };
}
