{ pkgs ? import <nixpkgs> { } }:

# A small bubbletea TUI calculator that shells out to `calc` (calc -qps).
# `calc` is installed separately in base.nix and must be on PATH at runtime.
pkgs.buildGoModule {
  pname = "bubblecalc";
  version = "0.1.0";

  src = ./bubblecalc;

  vendorHash = "sha256-Bp9kcUebTki/MRGFBReLvbN9+4Pm5NS7oHR2ZHkoH0I=";

  meta = with pkgs.lib; {
    description = "Bubbletea TUI calculator wrapping the `calc` CLI";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "bubblecalc";
  };
}
