{
	description = "Xein's NixOS config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs"; # makes hm follow system packages
		};
		hy3.url = "github:outfoxxed/hy3";
	};

	outputs = { nixpkgs, home-manager, hy3, ... }: let
		system = "x86_64-linux";
		hyprland = hy3.inputs.hyprland;
	in {
		nixosConfigurations.kaveh = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit hyprland system; };
			modules = [ 
				./configuration.nix 
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.xein = import ./xein.nix;
						backupFileExtension = "backup";
						extraSpecialArgs = {
							hy3Package = hy3.packages.${system}.hy3;
							hyprlandPackage = hyprland.packages.${system}.hyprland;
						};
					};
				}
			];
		};
	};
}

