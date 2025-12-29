{
  description = "reima-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nvf.url = "github:notashelf/nvf";
    fsel.url = "github:Mjoyufull/fsel";
    # kickstart-nix-nvim.url = "path:/home/reima/nix/modules/kickstart-nix-nvim/";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, stylix, home-manager, fsel, ... }:
    let
      hosts = [ "thinkpad-carbon" "thinkpad" "thinkcentre" "asusprime" ];

      defaultSystem = "x86_64-linux";
      systemsByHost = { };
      systemFor = host:
        nixpkgs.lib.attrByPath [ host ] defaultSystem systemsByHost;

      mkModules = host: [
        stylix.nixosModules.stylix
        {
          nixpkgs = {
            config.allowUnfree = true;
            # overlays = [kickstart-nix-nvim.overlays.default];
          };
        }
        ./hosts/${host}/configuration.nix
        ./hosts/${host}/hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          # home-manager.extraSpecialArgs = {inherit nvf;};
          # home-manager.sharedModules = [
          # nvf.homeManagerModules.default
          # ];
          home-manager.backupFileExtension = "backup";
          home-manager.useUserPackages = true;
          # home-manager.useGlobalPkgs = true; # toggle if you prefer
          home-manager.users.reima = import ./hosts/${host}/home.nix;
        }
        ({ pkgs,
          # nvf,
          ... }:
          # let
          #   nvim-nvf = pkgs.runCommand "nvim-nvf" {buildInputs = [pkgs.makeWrapper];} ''
          #     mkdir -p $out/bin
          #     makeWrapper ${nvf.packages.${pkgs.stdenv.system}.default}/bin/nvim \
          #       $out/bin/nvim-nvf \
          #       --set NVIM_APPNAME nvf
          #   '';
          # in
          {
            environment.systemPackages = [
              fsel.packages.${pkgs.stdenv.system}.default
              # pkgs."nvim-pkg"
              # nvim-nvf
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
          modules = [ ./hosts/${host}/home.nix ];
        };
      }) hosts);
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
        nixpkgs.lib.nixosSystem {
          system = systemFor host;
          # specialArgs = {inherit nvf;};
          modules = mkModules host;
        });

      homeConfigurations = mkHomeEntries;
    };
}
