{
	description = "Xein's NixOS config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs"; # makes hm follow system packages
		};
	};

	outputs = { nixpkgs, home-manager, ... }: {
		nixosConfigurations.kaveh = nixpkgs.lib.nixosSystem {
			modules = [ 
				./configuration.nix 
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.xein = import ./xein.nix;
						backupFileExtension = "backup";
					};
				}
			];
		};
	};
}

