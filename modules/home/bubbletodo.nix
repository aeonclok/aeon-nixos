{ pkgs ? import <nixpkgs> { } }:

# A small bubbletea TUI that POSTs a quick todo to the valolink engine.
# The API key is read at runtime from $TODO_API_KEY or
# ~/.config/bubbletodo/apikey (kept out of this repo). The endpoint can be
# overridden with $TODO_ENDPOINT.
pkgs.buildGoModule {
  pname = "bubbletodo";
  version = "0.1.0";

  src = ./bubbletodo;

  vendorHash = "sha256-mXnPYI/MdL7ugG7tQrVo1B/pNCT5RieYp+Zn0zvoXr4=";

  meta = with pkgs.lib; {
    description = "Bubbletea TUI to add a quick todo via the valolink engine API";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "bubbletodo";
  };
}
