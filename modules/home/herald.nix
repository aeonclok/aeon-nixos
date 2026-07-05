{ pkgs ? import <nixpkgs> { } }:

# Herald — TUI email + calendar client (Gmail OAuth, Google Calendar, vim profile).
# Source-available under FSL-1.1 (Apache-2.0 after two years), hence not in nixpkgs.
pkgs.buildGoModule rec {
  pname = "herald";
  version = "0.7.4-beta.1";

  src = pkgs.fetchFromGitHub {
    owner = "herald-email";
    repo = "herald-mail-app";
    rev = "v${version}";
    hash = "sha256-xiLlWhOlxrEmc2SemNmDd3nHaNAqd3x5aq0ypVSmTQI=";
  };

  vendorHash = "sha256-keK9JVcLMriE4/0bi2JKvXcgcM1UH6XqdoQ8chwoPwI=";

  subPackages = [ "cmd/herald" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/herald-email/herald-mail-app/internal/version.Version=v${version}"
  ];

  meta = with pkgs.lib; {
    description = "TUI email and calendar client with Gmail and Google Calendar support";
    homepage = "https://github.com/herald-email/herald-mail-app";
    license = licenses.fsl11Asl20;
    platforms = platforms.linux;
    mainProgram = "herald";
  };
}
