{ pkgs, ... }:
let
  # PhotoCraft, a Photoshop-like image editor in Rust (github.com/storytold/photocraft).
  # The release AppImage, wrapped; building from source needs a newer Rust than nixpkgs.
  # To update: bump version, set hash to "", rebuild and paste the hash it reports.
  pname = "photocraft";
  version = "0.15.1";
  src = pkgs.fetchurl {
    url = "https://github.com/storytold/photocraft/releases/download/v${version}/photocraft-${version}-linux-x86_64.AppImage";
    hash = "sha256-fZbz0NoZIdY0YgsNTNo3y/M1OnZ/kguQbOHGZnOA/+0=";
  };
  contents = pkgs.appimageTools.extract { inherit pname version src; };
  photocraft = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    # AppRun would otherwise write its own desktop entry and icons into
    # ~/.local/share on every launch; the ones installed below do that job.
    profile = "export PHOTOCRAFT_NO_DESKTOP_INTEGRATION=1";
    extraInstallCommands = ''
      install -Dm444 ${contents}/ai.storyteller.photocraft.desktop -t $out/share/applications
      cp -r ${contents}/usr/share/icons $out/share/
    '';
  };
in
{
  home.packages = [ photocraft ];
}
