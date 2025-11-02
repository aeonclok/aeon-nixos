{ lib ? (import <nixpkgs> { }).lib }:

let
  palette = {
    bg_dim = "#1B1B1B";
    bg0 = "#282828";
    bg1 = "#32302F";
    bg2 = "#32302F";
    bg3 = "#45403D";
    bg4 = "#45403D";
    bg5 = "#5A524C";

    bg_diff_red = "#402120";
    bg_diff_green = "#34381B";
    bg_diff_blue = "#0E363E";

    bg_statusline1 = "#32302F";
    bg_statusline2 = "#3A3735";
    bg_statusline3 = "#504945";
    bg_current_word = "#3C3836";

    bg_visual_red = "#4C3432";
    bg_visual_green = "#3B4439";
    bg_visual_blue = "#374141";
    bg_visual_yellow = "#4F422E";
    bg_visual_purple = "#443840";

    fg0 = "#D4BE98";
    fg1 = "#DDC7A1";

    red = "#EA6962";
    green = "#A9B665";
    blue = "#7DAEA3";
    yellow = "#D8A657";
    purple = "#D3869B";
    orange = "#E78A4E";
    aqua = "#89B482";

    grey0 = "#7C6F64";
    grey1 = "#928374";
    grey2 = "#A89984";
  };

  toEnvName = n:
    "THEME_${
      lib.strings.toUpper (lib.strings.replaceStrings [ "-" ] [ "_" ] n)
    }";

  sessionVariables = lib.listToAttrs (lib.mapAttrsToList (n: v: {
    name = toEnvName n;
    value = v;
  }) palette);

in { inherit palette sessionVariables; }
