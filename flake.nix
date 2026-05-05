{
  description = "reima-nixos";

  # Inputs are external dependencies (repositories) that your system needs to build.
  inputs = {
    # The core NixOS package repository. You are tracking the rolling 'unstable' branch.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager handles user-specific dotfiles and packages.
    home-manager.url = "github:nix-community/home-manager";
    # This tells Home Manager to use the exact same version of nixpkgs defined above,
    # preventing duplicate packages and saving disk space.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # A custom fuzzy selector tool you are pulling directly from GitHub.
    fsel.url = "github:Mjoyufull/fsel";

    # Stylix handles system-wide theming (colors, fonts, wallpapers).
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs"; # Again, keeping nixpkgs in sync.
    };

    # Astal and AGS are tools for building custom desktop widgets/bars.
    astal.url = "github:aylur/astal";
    ags.url = "github:aylur/ags";
  };

  # Outputs are the actual configurations this flake produces based on the inputs.
  # The `@inputs` syntax makes all the inputs easily accessible as a single variable.
  outputs =
    {
      nixpkgs,
      stylix,
      home-manager,
      fsel,
      ...
    }@inputs:
    let
      # A list of all the machines you are managing with this flake.
      hosts = [
        "thinkpad-carbon"
        "thinkpad"
        "thinkcentre"
        "asusprime"
      ];

      # System architecture definitions.
      defaultSystem = "x86_64-linux"; # Default to standard 64-bit Intel/AMD architecture.
      systemsByHost = { }; # You could override architectures for specific hosts here (e.g., if one was an ARM Mac).

      # A helper function that looks up the system type for a given host,
      # falling back to 'defaultSystem' if not explicitly defined in 'systemsByHost'.
      systemFor = host: nixpkgs.lib.attrByPath [ host ] defaultSystem systemsByHost;

      # A helper function that bundles all the necessary NixOS modules for a specific host.
      # This keeps your output block clean instead of repeating this for every machine.
      mkModules = host: [
        # 1. Enable Stylix for system theming
        stylix.nixosModules.stylix

        # 2. Configure standard Nixpkgs settings
        {
          nixpkgs = {
            config.allowUnfree = true; # Allow proprietary software (like NVIDIA drivers, Spotify, etc.)
            # overlays = [kickstart-nix-nvim.overlays.default];
          };
        }

        # 3. Import the specific configuration files for whichever machine is currently building
        ./hosts/${host}/configuration.nix
        ./hosts/${host}/hardware-configuration.nix

        # 4. Integrate Home Manager directly into the NixOS build process.
        # This means running `nixos-rebuild switch` will update both system and user environments simultaneously.
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "backup"; # Backs up existing dotfiles instead of failing if they conflict.
          home-manager.extraSpecialArgs = { inherit inputs; }; # Passes your flake inputs (like ags/astal) into Home Manager.

          # Modules available to all Home Manager configurations.
          home-manager.sharedModules = [
            # nvf.homeManagerModules.default
            inputs.ags.homeManagerModules.default # Enables AGS configuration inside home.nix
          ];

          # Installs packages to /etc/profiles instead of ~/.nix-profile. Usually cleaner.
          home-manager.useUserPackages = true;
          # home-manager.useGlobalPkgs = true; # toggle if you prefer

          # Import the specific user configuration for this machine.
          home-manager.users.reima = import ./hosts/${host}/home.nix;
        }

        # 5. An inline module to add specific flake packages into the system environment.
        (
          {
            pkgs,
            ...
          }:
          {
            environment.systemPackages = [
              # Grabs the 'default' package from your 'fsel' flake input and installs it.
              fsel.packages.${pkgs.stdenv.system}.default
            ];
          }
        )
      ];

      # This creates standalone Home Manager configurations (e.g., if you wanted to run
      # `home-manager switch --flake .#reima@thinkpad` without doing a full NixOS rebuild).
      mkHomeEntries = builtins.listToAttrs (
        map (host: {
          name = "reima@${host}";
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = systemFor host;
              config.allowUnfree = true;
            };
            modules = [ ./hosts/${host}/home.nix ];
          };
        }) hosts
      );

      # This `in` block is what the flake actually exposes to the command line.
    in
    {
      # This attribute builds the full OS for each machine.
      # It iterates through your 'hosts' list and calls `nixpkgs.lib.nixosSystem` for each,
      # using the 'mkModules' helper function defined above.
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (
        host:
        nixpkgs.lib.nixosSystem {
          system = systemFor host;
          # specialArgs = {inherit nvf;};
          modules = mkModules host;
        }
      );

      # Exposes the standalone Home Manager configurations defined earlier.
      homeConfigurations = mkHomeEntries;
    };
}
