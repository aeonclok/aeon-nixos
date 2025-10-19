{ config, pkgs, ... }:
{
programs.wezterm = {
  enable = true;
  extraConfig = ''
local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.window_background_opacity = 0.80

config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  fade_in_function = "EaseIn",
  fade_out_function = "EaseOut",
}

config.hide_tab_bar_if_only_one_tab = true

config.freetype_load_target = "HorizontalLcd"
config.freetype_render_target = "HorizontalLcd"
config.cell_width = 0.9

-- REMOVE this when using custom colors:
-- config.color_scheme = "GruvboxDark"

-- === Catppuccin “mocha” with your overrides ===
local P = {
  base      = "#1d2021",
  mantle    = "#141414",
  crust     = "#141414",
  surface0  = "#32302f",
  surface1  = "#458588",
  surface2  = "#504945",
  overlay0  = "#665c54",
  overlay1  = "#7c6f64",
  overlay2  = "#928374",
  subtext0  = "#928374",
  subtext1  = "#458588",
  text      = "#d4be98",
  rosewater = "#ddc7a1",
  flamingo  = "#ea6962",
  red       = "#c14a4a",
  peach     = "#d3869b",
  yellow    = "#d4be98",
  green     = "#a9b665",
  teal      = "#89b482",
  blue      = "#7daea3",
  mauve     = "#e78a4e",
  sapphire  = "#458588",
}

config.colors = {
  foreground = P.text,
  background = P.base,

  cursor_bg = P.text,
  cursor_fg = P.base,
  cursor_border = P.text,

  selection_bg = P.surface0,
  selection_fg = P.text,

  scrollbar_thumb = P.surface2,
  split = P.surface2,

  -- 16-color ANSI palette
  ansi = {
    P.base,     -- black
    P.red,      -- red
    P.green,    -- green
    P.yellow,   -- yellow
    P.blue,     -- blue
    P.peach,    -- magenta-ish (your palette's pink/purple leans warm)
    P.teal,     -- cyan
    P.text,     -- white
  },
  brights = {
    P.surface0, -- bright black
    P.flamingo, -- bright red
    P.green,    -- bright green
    P.rosewater,-- bright yellow
    P.blue,     -- bright blue
    P.mauve,    -- bright magenta
    P.teal,     -- bright cyan
    P.rosewater -- bright white
  },
}

config.font = wezterm.font({
  family = "MonaspiceNe NFM",
  harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
})
config.font_size = 12

config.font_rules = {
  {
    intensity = "Normal",
    italic = true,
    font = wezterm.font({
      family = "MonaspiceNe NFM",
      weight = "Light",
      style = "Italic",
      harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
    }),
  },
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font({
      family = "MonaspiceNe NFM",
      weight = "Bold",
      style = "Normal",
      harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
    }),
  },
}

return config
  '';
};
}
