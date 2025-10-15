{
  description = "reima-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      lib = pkgs.lib;
    in {
      nixosConfigurations = {
        nixos-laptop = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [
            ./hosts/nixos-laptop/hardware-configuration.nix
            ./hosts/nixos-laptop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/nixos-laptop/home.nix;
            }
          ];
        };
      };

      homeConfigurations."reima@nixos-laptop" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/nixos-laptop/home.nix ];
        };
    };
}

