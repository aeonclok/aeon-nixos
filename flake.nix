{
  description = "reima-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fsel.url = "github:Mjoyufull/fsel";
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, fsel, nvf, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              environment.systemPackages = [
                fsel.packages.${system}.default
              ];
            }
            ./hosts/thinkpad/configuration.nix
            ./hosts/thinkpad/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
	      home-manager.sharedModules = [
                nvf.homeManagerModules.default
              ];
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/thinkpad/home.nix;
            }
          ];
        };
        thinkcentre = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              environment.systemPackages = [
                fsel.packages.${system}.default
              ];
            }
            ./hosts/thinkcentre/configuration.nix
            ./hosts/thinkcentre/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                nvf.homeManagerModules.default
              ];
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/thinkcentre/home.nix;
            }
          ];
        };
        asusprime = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              environment.systemPackages = [
                fsel.packages.${system}.default
              ];
            }
            ./hosts/asusprime/configuration.nix
            ./hosts/asusprime/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                nvf.homeManagerModules.default
              ];
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/asusprime/home.nix;
            }
          ];
        };
      };

      homeConfigurations."reima@thinkpad" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [ ./hosts/thinkpad/home.nix ];
        };
      homeConfigurations."reima@thinkcentre" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [ ./hosts/thinkcentre/home.nix nvf.homeManagerModules.default ];
        };
      homeConfigurations."reima@asusprime" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [ ./hosts/asusprime/home.nix nvf.homeManagerModules.default ];
        };
    };
}

