{ config, pkgs, ... }: {
  # Make fonts available systemwide
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      inter
      cantarell-fonts
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerd-fonts.monaspace
    ];

    # Good, sane fontconfig defaults
    fontconfig = {
      enable = true;

      # Strong subpixel AA + light hinting works great on most LCDs
      antialias = true;
      hinting.enable = true;
      hinting.style =
        "slight"; # try "slight" first; "medium" if you prefer crisper
      subpixel.lcdfilter = "light";
      subpixel.rgba =
        "rgb"; # change to "bgr"/"vrgb"/"vbgr" if your panel is different
      allowBitmaps = false;

      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "Cantarell" ];
        monospace = [ "Monaspace Neon" "Monaspace Argon" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
