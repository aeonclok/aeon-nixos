# Majorlink's mail drafts (majorlink repo, MAJORLINK.md §2.3, step F): after
# every lieer sync, pair each reply Majorlink drafted with what the owner
# actually sent in that thread (bin/mail-pairs.ts). Quiet unless it pairs.
# Majorlink only reads the mail and inserts drafts outside lieer's folder; it
# never tags, so nothing here reaches Gmail.
{ pkgs, ... }:
{
  systemd.user.services.lieer-valolink.Unit.OnSuccess = [ "majorlink-mail-pairs.service" ];
  systemd.user.services.majorlink-mail-pairs = {
    Unit.Description = "Majorlink: pair mail drafts with what was sent";
    Service = {
      Type = "oneshot";
      WorkingDirectory = "%h/valolink/majorlink";
      Environment = [
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
        "PATH=${pkgs.notmuch}/bin"
      ];
      ExecStart = "${pkgs.nodejs}/bin/node --no-warnings bin/mail-pairs.ts";
    };
  };
}
