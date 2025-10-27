{
  description = "reima-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    fsel.url = "github:Mjoyufull/fsel";

    kickstart-nix-nvim.url = "path:/home/reima/nix/modules/kickstart-nix-nvim/";

  };

  outputs = { kickstart-nix-nvim, fsel, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        thinkpad-carbon = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # lix-module.nixosModules.default
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [ kickstart-nix-nvim.overlays.default ];
              };
            }
            ./hosts/thinkpad-carbon/configuration.nix
            ./hosts/thinkpad-carbon/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              # home-manager.useGlobalPkgs = true;
              home-manager.users.reima = import ./hosts/thinkpad-carbon/home.nix;
            }
    ({ pkgs, ... }: {
        environment.systemPackages = [
          fsel.packages.${pkgs.stdenv.system}.default

          pkgs."nvim-pkg"
        ];
      })     
	      
          ];
        };
        # thinkpad = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # lix-module.nixosModules.default
        #     {
        #       nixpkgs.config.allowUnfree = true;
        #       environment.systemPackages = [
        #         fsel.packages.${system}.default
        #       ];
        #     }
        #     ./hosts/thinkpad/configuration.nix
        #     ./hosts/thinkpad/hardware-configuration.nix
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useUserPackages = true;
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.users.reima = import ./hosts/thinkpad/home.nix;
        #     }
        #   ];
        # };
        # thinkcentre = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # lix-module.nixosModules.default
        #     {
        #       nixpkgs.config.allowUnfree = true;
        #       environment.systemPackages = [
        #         fsel.packages.${system}.default
        #       ];
        #     }
        #     ./hosts/thinkcentre/configuration.nix
        #     ./hosts/thinkcentre/hardware-configuration.nix
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useUserPackages = true;
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.users.reima = import ./hosts/thinkcentre/home.nix;
        #     }
        #   ];
        # };
        # asusprime = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # lix-module.nixosModules.default
        #     {
        #       nixpkgs.config.allowUnfree = true;
        #       environment.systemPackages = [
        #         fsel.packages.${system}.default ]; } ./hosts/asusprime/configuration.nix
        #     ./hosts/asusprime/hardware-configuration.nix
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useUserPackages = true;
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.users.reima = import ./hosts/asusprime/home.nix;
        #     }
        #   ];
        # };
      };

      homeConfigurations."reima@thinkpad-carbon" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [ ./hosts/thinkpad-carbon/home.nix ];
        };
    #   homeConfigurations."reima@thinkpad" =
    #     home-manager.lib.homeManagerConfiguration {
    #       pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    #       modules = [ ./hosts/thinkpad/home.nix ];
    #     };
    #   homeConfigurations."reima@thinkcentre" =
    #     home-manager.lib.homeManagerConfiguration {
    #       pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    #       modules = [ ./hosts/thinkcentre/home.nix ];
    #     };
    #   homeConfigurations."reima@asusprime" =
    #     home-manager.lib.homeManagerConfiguration {
    #       pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    #       modules = [ ./hosts/asusprime/home.nix ];        };
    };
}

