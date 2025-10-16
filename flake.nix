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
    in {
      nixosConfigurations = {
        thinkcentre = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [
            ./hosts/thinkcentre/configuration.nix
            ./hosts/thinkcentre/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/thinkcentre/home.nix;
            }
          ];
        };
      };

      homeConfigurations."reima@thinkcentre" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/thinkcentre/home.nix ];
        };
    };
}

