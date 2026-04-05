{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles/config";
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
		delta
		fd
		ripgrep
		fzf
		tree-sitter
    p7zip

    #LSP
		nixd
		emmylua-ls
    prettier

		# GitHub tools
    lazygit
    gh-dash
		github-cli
		github-copilot-cli
	];
}
