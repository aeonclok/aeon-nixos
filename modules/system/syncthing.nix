# Cross-machine file sync via Syncthing, peer-to-peer over Tailscale.
# Imported only by the hosts that should participate (thinkpad-carbon +
# asusprime for now). asusprime is on 24/7, so it acts as the always-available
# peer / de-facto hub and holds the versioning (trash-can) copy.
#
# Two-phase rollout:
#   1. With the REPLACE-* placeholder IDs below, Syncthing just starts and
#      generates each host's key on first rebuild (no peers, no folders shared).
#   2. Read each host's Device ID (see command below), drop the two PUBLIC ids
#      in here, rebuild both hosts — pairing + the valolink folder go live.
#
# Read a host's Device ID after its first rebuild:
#   journalctl -u syncthing -g 'My ID' -n1     (or the web GUI at :8384)
#
# Device IDs are PUBLIC (derived from each host's public key) and safe to
# commit. The private key is auto-generated per host under /var/lib/syncthing
# and never enters git.
{ config, lib, ... }:
let
  # Tailscale IPs are stable per node; using them avoids MagicDNS naming
  # surprises — this host currently appears as `thinkpad-carbon-1` on the
  # tailnet because the retired X1 still holds the `thinkpad-carbon` name.
  hosts = {
    thinkpad-carbon = {
      id = "UIGOSZL-3I4CKTJ-5WGCFX6-RULXXVS-NRY2TQ6-5PMS27J-VHOOHMA-KCVSXQC";
      ip = "100.64.177.71";
    };
    asusprime = {
      id = "REPLACE-ASUSPRIME";
      ip = "100.88.114.20";
    };
  };
  # Only wire up devices whose real ID has been filled in.
  known = lib.filterAttrs (_: h: !(lib.hasPrefix "REPLACE" h.id)) hosts;
in
{
  services.syncthing = {
    enable = true;
    user = "reima";
    group = "users";
    # We run as reima (needed for write access to ~/valolink), so the state
    # dirs must live somewhere reima owns: the module only auto-creates
    # /var/lib/syncthing for its own default `syncthing` user.
    configDir = "/home/reima/.config/syncthing";
    dataDir = "/home/reima/.local/share/syncthing";
    databaseDir = "/home/reima/.local/share/syncthing";
    # nix is the source of truth — the GUI can't add/remove devices or folders.
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      options = {
        # Private tailnet only: no public discovery, relays, NAT traversal, or
        # anonymous usage reporting. Peers are reached via explicit Tailscale
        # addresses below.
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
      devices = lib.mapAttrs (_: h: {
        inherit (h) id;
        addresses = [ "tcp://${h.ip}:22000" ];
      }) known;
      folders.valolink = {
        path = "/home/reima/valolink";
        # Share with every known host (Syncthing ignores the self entry).
        devices = lib.attrNames known;
        # Keep the recoverable "trash can" on the always-on hub.
        versioning = lib.mkIf (config.networking.hostName == "asusprime") {
          type = "staggered";
          params.cleanoutDays = "90";
        };
      };
    };
  };

  # Pre-create the state dirs owned by reima (syncthing self-creates only the
  # leaf, and only where it has write access — guarantee the parents exist).
  systemd.tmpfiles.rules = [
    "d /home/reima/.config/syncthing 0700 reima users - -"
    "d /home/reima/.local/share/syncthing 0700 reima users - -"
  ];

  # Syncthing's sync port, opened only on the Tailscale interface (never public).
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };
}
