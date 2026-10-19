# Majorlink's phone gateway (majorlink repo, MAJORLINK.md §13 step I): the
# Android app speaks to asusprime over Tailscale; bin/phone-gateway.ts
# transcribes here and hands the text to the capture agent, as Mod+Space does.
# It listens on 127.0.0.1:8740 only; `tailscale serve --bg 8740` (run once,
# it persists in tailscaled) puts it on the tailnet over HTTPS and tells it
# who is calling. Audio stays on the owner's own devices.
{ ... }:
{
  systemd.user.services.majorlink-phone = {
    Unit = {
      Description = "Majorlink: the phone gateway";
      After = [ "network-online.target" ];
    };
    Service = {
      WorkingDirectory = "%h/valolink/majorlink";
      # whisper-cli, opencode and node come from the user's profile; tailscale
      # and the shell tools from the system.
      Environment = [ "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin" ];
      ExecStart = "/etc/profiles/per-user/%u/bin/node --experimental-strip-types --no-warnings bin/phone-gateway.ts";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
