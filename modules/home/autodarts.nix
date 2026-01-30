{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "autodarts-desktop";
  version = "0.27.0"; # UPDATE THIS to the version you are downloading

  src = pkgs.fetchurl {
    # UPDATE THIS URL
    url =
      "https://get.autodarts.io/desktop/linux/x64/autodarts-desktop_1.5.0_amd64.deb";
    # UPDATE THIS HASH (from nix-prefetch-url)
    sha256 = "1zln579f87x8w53wfv5lpyrx135n7991rhl75496bywki9milix4";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
    # binutils is needed for 'ar'
    pkgs.binutils
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    mesa
    nspr
    nss
    pango
    systemd
    udev
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libxkbfile
    libxshmfence
    libxkbcommon
  ];

  # FIX: Manually unpack to ignore SUID permission errors on chrome-sandbox
  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share $out/lib

    # Copy the main application files
    # Based on your log, the files are in usr/lib/autodarts-desktop
    cp -r usr/share/* $out/share/
    cp -r usr/lib/autodarts-desktop $out/lib/

    # Link the binary to /bin
    ln -s $out/lib/autodarts-desktop/autodarts-desktop $out/bin/autodarts-desktop

    # Fix the .desktop file so your launcher finds it
    substituteInPlace $out/share/applications/autodarts-desktop.desktop \
      --replace "/usr/bin/autodarts-desktop" "$out/bin/autodarts-desktop"

    runHook postInstall
  '';

  postFixup = ''
    # We add --no-sandbox because we cannot install the SUID chrome-sandbox helper
    wrapProgram $out/bin/autodarts-desktop \
      --add-flags "--no-sandbox \''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [ pkgs.udev pkgs.libglvnd ]
      }
  '';

  meta = with pkgs.lib; {
    description = "Autodarts Desktop Client";
    homepage = "https://autodarts.io";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "autodarts-desktop";
  };
}
