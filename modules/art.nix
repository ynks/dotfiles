{ pkgs, ... }:

{
  home.packages = with pkgs; [
    blender
    davinci-resolve
  ];
}
