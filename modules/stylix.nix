{ config, pkgs, ... }:
# Shared Stylix theme settings. The option names are identical in the NixOS and
# Home Manager stylix modules, so this file is imported from both:
#   - modules/system/base.nix (integrated builds; stylix propagates into HM itself)
#   - flake.nix mkHomeEntries (standalone `home-manager switch` outputs)
{
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.image = ./system/background.jpg;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.monaspace;
      name = "MonaspiceNe Nerd Font";
    };
    serif = config.stylix.fonts.monospace;
    # sansSerif = config.stylix.fonts.monospace;
    emoji = config.stylix.fonts.monospace;
  };
}
