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

    # Stylix handles system-wide theming (colors, fonts, wallpapers).
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs"; # Again, keeping nixpkgs in sync.
    };

    # Community flake that packages the latest Claude Code CLI (fresher than nixpkgs).
    # Bump with `nix flake update claude-code-nix`.
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs are the actual configurations this flake produces based on the inputs.
  # The `@inputs` syntax makes all the inputs easily accessible as a single variable.
  outputs =
    {
      nixpkgs,
      stylix,
      home-manager,
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

      # The one nixpkgs configuration, shared by the NixOS builds (and through
      # useGlobalPkgs their Home Manager) and the standalone HM entries.
      nixpkgsConfig = {
        allowUnfree = true; # Allow proprietary software (like NVIDIA drivers, Spotify, etc.)
        permittedInsecurePackages = [
          "electron-39.8.10"
        ];
      };
      # Overrides pkgs.claude-code with the sadjow/claude-code-nix build.
      overlays = [ inputs.claude-code-nix.overlays.default ];

      # A helper function that bundles all the necessary NixOS modules for a specific host.
      # This keeps your output block clean instead of repeating this for every machine.
      mkModules = host: [
        # 1. Enable Stylix for system theming
        stylix.nixosModules.stylix

        # 2. Configure standard Nixpkgs settings
        {
          nixpkgs = {
            config = nixpkgsConfig;
            inherit overlays;
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
          home-manager.extraSpecialArgs = { inherit inputs; }; # Passes your flake inputs into Home Manager.

          # Home Manager uses the system's pkgs (config + overlays above) instead
          # of evaluating its own nixpkgs instance.
          home-manager.useGlobalPkgs = true;

          # Installs packages to /etc/profiles instead of ~/.nix-profile. Usually cleaner.
          home-manager.useUserPackages = true;

          # Import the specific user configuration for this machine.
          home-manager.users.reima = import ./hosts/${host}/home.nix;
        }
      ];

      # This creates standalone Home Manager configurations (e.g., if you wanted to run
      # `home-manager switch --flake .#reima@thinkpad` without doing a full NixOS rebuild).
      # It must mirror what the integrated setup provides: `inputs` via specialArgs, the
      # stylix HM module, the shared nixpkgs config + overlays, and the shared stylix theme
      # (which the NixOS stylix module would otherwise propagate into HM).
      mkHomeEntries = builtins.listToAttrs (
        map (host: {
          name = "reima@${host}";
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = systemFor host;
              config = nixpkgsConfig;
              inherit overlays;
            };
            extraSpecialArgs = { inherit inputs; };
            modules = [
              stylix.homeModules.stylix
              ./modules/stylix.nix
              ./hosts/${host}/home.nix
            ];
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
          modules = mkModules host;
        }
      );

      # Exposes the standalone Home Manager configurations defined earlier.
      homeConfigurations = mkHomeEntries;
    };
}
