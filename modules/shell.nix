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
		setopt PROMPT_PERCENT

		set_my_prompt() {
			if [[ -n "$IN_NIX_SHELL" ]]; then
				PROMPT='%F{cyan}%n@nix-shell%f %~ %F{white}>%f '
			else
				PROMPT='%F{magenta}%n@%m%f %~ %F{white}>%f '
					fi
		}

		precmd_functions+=(set_my_prompt)
	'';
    shellAliases = {
      nv = "fd --hidden --type f --exclude .git | fzf --reverse | xargs nvim";
      rebuild = "sudo nixos-rebuild switch --flake ~/Code/dotfiles#$(hostname)";
      devenv = "nix develop --command zsh";
      rider = "nohup rider >/dev/null 2>&1 &";
      clion = "nohup clion >/dev/null 2>&1 &";
      ".." = "cd ..";
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
      pull.rebase = true;
      rebase.autoStash = true;
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
