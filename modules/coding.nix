{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Code/dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in

{
  xdg.configFile.nvim = {
    source = create_symlink "${dotfiles}/nvim";
    recursive = true;
  };

  xdg.configFile.lazygit = {
    source = create_symlink "${dotfiles}/lazygit";
    recursive = true;
  };

  home.packages = with pkgs; [
    # Editors & IDEs
    neovim
    jetbrains.clion
    jetbrains.rider

    # Development tools
    lua
    lua55Packages.luarocks_bootstrap
    fd
    ripgrep
    fzf
    tree-sitter
    p7zip
    renderdoc

    # GitHub tools
    lazygit
    gh-dash
    github-cli
    smartgit
    gitkraken
    bcompare

    # AI assistants
    opencode
    claude-code
  ];
}
