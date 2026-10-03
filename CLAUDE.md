# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal NixOS + Home Manager flake managing four machines: `thinkpad-carbon`, `thinkpad`, `thinkcentre`, `asusprime`. All hosts share most config; per-host files only carry hardware and hostname differences.

## Common commands

Rebuild the current host (uses hostname):

```sh
sudo nixos-rebuild switch --flake .#$(hostname)
```

Or via `nh` (already installed):

```sh
nh os switch               # build + switch; NH_FLAKE (programs.nh.flake) points at this repo
nh os boot                 # stage for next boot
```

Standalone Home Manager (without full rebuild) — outputs are exposed as `reima@<host>`:

```sh
home-manager switch --flake .#reima@thinkpad
```

Update inputs / lock file:

```sh
nix flake update
nix flake lock --update-input nixpkgs   # update a single input
```

Format Nix code: `nixfmt` (primary) or `nixpkgs-fmt`. Lint: `statix` (config in `statix.toml`; `repeated_keys` is disabled on purpose), `deadnix` (skip the generated `hardware-configuration.nix` files).

## Architecture

`flake.nix` is the orchestrator. It defines:

- `hosts` — the list of machine names. Adding a host requires both an entry here and a `hosts/<host>/` directory containing `configuration.nix`, `hardware-configuration.nix`, and `home.nix`.
- `mkModules host` — builds the module list for `nixosSystem`. It wires Stylix, the shared `nixpkgsConfig` (allowUnfree, permittedInsecurePackages) + `overlays` (claude-code-nix), the host's two system files, and Home Manager (integrated into the NixOS build with `useGlobalPkgs = true`, so HM uses the system pkgs; don't set `nixpkgs.*` inside HM modules).
- `mkHomeEntries` — also exposes each host's `home.nix` as a standalone `homeConfigurations."reima@<host>"` so you can iterate on user config without a full system rebuild.

Home Manager is **integrated** (`home-manager.nixosModules.home-manager`), so `nixos-rebuild switch` updates the user environment too. `home-manager.useUserPackages = true` installs to `/etc/profiles`.

### Layout

- `hosts/<host>/configuration.nix` — typically just imports `modules/system/base.nix`, sets hostname and `stateVersion`. `asusprime` is the outlier (Intel GPU + Ollama + podman + swapfile).
- `hosts/<host>/home.nix` — imports `modules/home/base.nix` + a few feature modules (`fish`, `wezterm`, `waybar`, `tmux`). All four hosts import the same set; thinkpad-carbon also imports `mail.nix`.
- `modules/system/base.nix` — the real system config: locale (en_US with fi_FI regional), keyboard (fi, caps→escape), pipewire, bluetooth, networkmanager, openssh (key-only, firewall closed), tailscale, GDM+Wayland, nh (weekly `nh clean`, keeps 5 generations / 7 days) + weekly `nix.optimise`, Niri as the sole compositor, the `reima` user (fish shell, wheel+networkmanager), and Claude Code managed settings at `/etc/claude-code/managed-settings.json` (disables commit/PR attribution and the session-URL trailer on every host; `~/.claude/settings.json` is deliberately left unmanaged so Claude Code can still write to it). Note: `tailscale.extraUpFlags = [ "--ssh" ]` is only applied by the autoconnect service (needs `authKeyFile`); since `tailscale up` was run manually, Tailscale SSH must be enabled per machine with `sudo tailscale set --ssh`.
- `modules/system/fonts.nix` — system fonts (Noto incl. color emoji, Inter, Monaspace) + fontconfig, imported by `base.nix` on every host. `modules/system/syncthing.nix` — Syncthing over Tailscale, imported by thinkpad-carbon and asusprime only.
- `modules/stylix.nix` — shared Stylix theme settings (`gruvbox-dark-hard`, Monaspice Nerd Font), imported by both `modules/system/base.nix` and the standalone HM entries in `flake.nix` (the option names are identical in the NixOS and HM stylix modules).
- `modules/home/base.nix` — the largest file. User packages, rclone gdrive mount as a user systemd service, xdg desktop entries for WhatsApp/Zulip (Chromium PWAs), GTK/Qt theming, fastfetch config, git identity.
- `modules/home/{fish,waybar,wezterm,tmux,nvim,starship,autodarts}.nix` — feature modules, opt-in per host.
- `modules/home/bubblecalc/` — Go sources for a small TUI calculator, packaged by `modules/home/bubblecalc.nix` (`buildGoModule`) and installed via `base.nix`.

Hyprland was removed; Niri is now the only compositor. (`modules/home/waybar-dev.sh` is a leftover from the Hyprland binds.)

### Live-edit symlinks (important)

Two configs are symlinked back into this repo via `mkOutOfStoreSymlink`, so edits take effect immediately without `nixos-rebuild`:

- `~/.config/niri/config.kdl` → `/home/reima/nix/modules/home/niriconf.kdl`
- `~/.config/nvim/` → `/home/reima/nix/modules/home/nvim/`

The `nvim/` directory is a LazyVim starter (managed by Lazy.nvim, with its own `lazy-lock.json`) — it is **not** a Nix-managed neovim configuration. Plugin changes are made by editing Lua files directly; `:Lazy sync` updates `lazy-lock.json`.

### Theming

Stylix is the single source of truth for colors and fonts. Base16 scheme is `gruvbox-dark-hard`. A separate `modules/home/gruvbox-palette.nix` exports the same palette as `THEME_*` env vars for tools that don't read base16 (consumed in `base.nix`'s `home.sessionVariables`).

### Flake inputs of note

- `stylix`, `claude-code-nix` — follow the flake's `nixpkgs` to avoid duplicates.

## Conventions

- The user's primary email in commits is `reima.kokko@valolink.fi`. A conditional `gitdir:~/valolink/` include in `programs.git` keeps the same identity and switches to `~/.ssh/id_valolink` for that tree.
- `allowUnfree` and other nixpkgs config live only in `nixpkgsConfig` in `flake.nix` (shared by NixOS, integrated HM, and the standalone HM entries).
- `stateVersion` is `25.05` on all hosts — don't bump without intent.
