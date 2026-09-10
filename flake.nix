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
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The dots repo is not a flake -- we only want its `hypr/` Lua tree.
    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };

    # Third-party greetd frontend; upstream Caelestia ships no greeter.
    caelestia-greeter = {
      url = "github:dim-ghub/Caelestia-Greeter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "caelestia-shell/quickshell";
      inputs.m3shapes.follows = "caelestia-shell/m3shapes";
    };
    sidra = {
      url = "github:wimpysworld/sidra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, plasma-manager, ... }:
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
          extraSpecialArgs = { inherit plasma-manager inputs; };
        };
      }
    ];
  in {
    nixosConfigurations.kaveh = nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = { inherit inputs; };
      modules = shared-modules ++ [ ./hosts/kaveh/default.nix ];
    };
    nixosConfigurations.cyno = nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = { inherit inputs; };
      modules = shared-modules ++ [ ./hosts/cyno/default.nix ];
    };
  };
}
