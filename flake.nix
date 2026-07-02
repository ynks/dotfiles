{
  description = "Xein's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }:
  let
    system = "x86_64-linux";
    shared-modules = [
      ./configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.xein = import ./xein.nix;
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit plasma-manager; };
        };
      }
    ];
  in {
    nixosConfigurations.kaveh = nixpkgs.lib.nixosSystem {
      system = system;
      modules = shared-modules ++ [ ./hosts/kaveh/default.nix ];
    };
    nixosConfigurations.cyno = nixpkgs.lib.nixosSystem {
      system = system;
      modules = shared-modules ++ [ ./hosts/cyno/default.nix ];
    };
  };
}
