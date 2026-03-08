{ ... }:

{
	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;
		enableCompletion = true;
		historySubstringSearch.enable = true;
		history = {
			size = 10000;
			save = 10000;
		};
		initContent = ''
			PROMPT='%F{green}[%n@%m]%f %~ %F{white}>%f '
		'';
		shellAliases = {
			n = "nvim";
			g = "git";
			rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#kaveh";
		};
	};

	programs.git = {
		enable = true;
		lfs.enable = true;

		settings = {
			user.name = "Xein";
			user.email = "xgonip@gmail.com";
			core.editor = "nvim";
			init.defaultBranch = "main";
			push.autoSetupRemote = true;
		};
	};

	programs.delta = {
		enable = true;
		enableGitIntegration = true;
		options = {
			navigate = true;
			side-by-side = true;
		};
	};

	programs.yazi = {
		enable = true;
		enableZshIntegration = true;
		shellWrapperName = "y";
	};

	programs.eza = {
		enable = true;
		icons = "auto";
		enableZshIntegration = true;
	};

	programs.zoxide = {
		enable = true;
		enableZshIntegration = true;
		options = [ "--cmd cd" ];
	};
}
