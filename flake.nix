{
  description = "reima-nixos";

  inputs = {
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fsel.url = "github:Mjoyufull/fsel";
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, fsel, nvf, nixpkgs, home-manager, lix, lix-module, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        thinkpad-carbon = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # ./machines/your-box
            lix-module.nixosModules.default
            {
              nixpkgs.config.allowUnfree = true;
              environment.systemPackages = [
                fsel.packages.${system}.default
              ];
            }
            ./hosts/thinkpad-carbon/configuration.nix
            ./hosts/thinkpad-carbon/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
	      home-manager.sharedModules = [
                nvf.homeManagerModules.default
              ];
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/thinkpad-carbon/home.nix;
            }
          ];
        };
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

      homeConfigurations."reima@thinkpad-carbon" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [ ./hosts/thinkpad-carbon/home.nix ];
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

