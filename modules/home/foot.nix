# foot, the lightweight terminal, for TUIs that should appear at once: the
# foot server runs from login and footclient opens a window in milliseconds,
# where a wezterm with its own --config starts a whole new GUI process.
# bubblekeys (Mod+?) opens in it. Same colours, font and transparency as
# wezterm, from terminal-palette.nix.
{ lib, ... }:
let
  P = import ./terminal-palette.nix;
  hex = c: lib.removePrefix "#" c;
in
{
  # The colours come from the shared palette, not from stylix.
  stylix.targets.foot.enable = false;

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main.font = "MonaspiceNe NFM:size=12";
      # As in wezterm.nix: ansi, then brights.
      colors-dark = {
        alpha = 0.80;
        foreground = hex P.text;
        background = hex P.base;
        cursor = "${hex P.base} ${hex P.text}";
        selection-foreground = hex P.text;
        selection-background = hex P.surface0;
        regular0 = hex P.base;
        regular1 = hex P.red;
        regular2 = hex P.green;
        regular3 = hex P.yellow;
        regular4 = hex P.blue;
        regular5 = hex P.peach;
        regular6 = hex P.teal;
        regular7 = hex P.text;
        bright0 = hex P.surface0;
        bright1 = hex P.flamingo;
        bright2 = hex P.green;
        bright3 = hex P.rosewater;
        bright4 = hex P.blue;
        bright5 = hex P.mauve;
        bright6 = hex P.teal;
        bright7 = hex P.rosewater;
      };
    };
  };
}
