{ pkgs ? import <nixpkgs> { } }:

# niri's keybinds as a cheat sheet to filter: grouped, in the terminal's colours.
pkgs.buildGoModule {
  pname = "bubblekeys";
  version = "0.1.0";

  src = ./bubblekeys;

  vendorHash = "sha256-RNbS40G+8rtwlSJgYLN1puTCytGfXdagQTEs6sIXwnM=";

  meta = with pkgs.lib; {
    description = "Bubbletea cheat sheet of the niri keybinds";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "bubblekeys";
  };
}
