{
  description = "reima-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    fsel.url = "github:Mjoyufull/fsel";
    kickstart-nix-nvim.url = "path:/home/reima/nix/modules/kickstart-nix-nvim/";
  };

  outputs = {
    nixpkgs,
    home-manager,
    fsel,
    kickstart-nix-nvim,
    ...
  }: let
    hosts = [
      "thinkpad-carbon"
      "thinkpad"
      "thinkcentre"
      "asusprime"
    ];

    defaultSystem = "x86_64-linux";
    systemsByHost = {
    };
    systemFor = host: nixpkgs.lib.attrByPath [host] defaultSystem systemsByHost;

    mkModules = host: [
      {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [kickstart-nix-nvim.overlays.default];
        };
      }
      ./hosts/${host}/configuration.nix
      ./hosts/${host}/hardware-configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        # home-manager.useGlobalPkgs = true; # toggle if you prefer
        home-manager.users.reima = import ./hosts/${host}/home.nix;
      }

      ({pkgs, ...}: {
        environment.systemPackages = [
          fsel.packages.${pkgs.stdenv.system}.default
          pkgs."nvim-pkg"
        ];
      })
    ];

    mkHomeEntries = builtins.listToAttrs (map (host: {
        name = "reima@${host}";
        value = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = systemFor host;
            config.allowUnfree = true;
          };
          modules = [./hosts/${host}/home.nix];
        };
      })
      hosts);
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
      nixpkgs.lib.nixosSystem {
        system = systemFor host;
        modules = mkModules host;
      });

    homeConfigurations = mkHomeEntries;
  };
}
