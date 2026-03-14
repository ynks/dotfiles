{
	description = "Self-hosted ai enviroment";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		claude-code-nix.url = "github:sadjow/claude-code-nix";
	};

	outputs = { self, nixpkgs, claude-code-nix, ... }:
	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			config.allowUnfree = true;
		};
	in {
		devShells.${system}.default = pkgs.mkShell {
			buildInputs = [
				claude-code-nix.packages.${system}.claude-code
				pkgs.ollama
				pkgs.nodejs_20
			];

			shellHook = ''
				export ANTHROPIC_AUTH_TOKEN="ollama"
				export ANTHROPIC_BASE_URL="http://localhost:11434"

				echo "Opened AI enviroment"

				alias ai="claude --model qwen2.5-coder:7b"
				alias ai-pro="claude --model qwen2.5-coder"14b"
				alias ai-deep="claude --model codestral"

				if ! pgrep -x "ollama" > /dev/null; then
					echo "WARN: Ollama doesn't look like its running"
				fi
			'';
		};
	};
}
