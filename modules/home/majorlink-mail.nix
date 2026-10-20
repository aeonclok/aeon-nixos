# Majorlink's mail drafts (majorlink repo, MAJORLINK.md §2.3, step F): after
# every lieer sync, pair each reply Majorlink drafted with what the owner
# actually sent in that thread (bin/mail-pairs.ts). Quiet unless it pairs.
# Majorlink only reads the mail and inserts drafts outside lieer's folder; it
# never tags, so nothing here reaches Gmail.
{ pkgs, ... }:
{
  systemd.user.services.lieer-valolink.Unit.OnSuccess = [ "majorlink-mail-pairs.service" ];
  # Mail cleanup by the rules he agreed to (~/.config/majorlink/mail-rules, majorlink
  # bin/mail-cleanup.ts): after Laya's triage, so the rules see its tags; also
  # when the triage fails, since the rules do not depend on it. In "tila:
  # harjoitus" it only says what it would do. Its tag changes reach Gmail on the
  # next lieer sync; every change is logged and a batch can be undone.
  systemd.user.services.mail-triage.Unit.OnSuccess = [ "majorlink-mail-cleanup.service" ];
  systemd.user.services.mail-triage.Unit.OnFailure = [ "majorlink-mail-cleanup.service" ];
  systemd.user.services.majorlink-mail-cleanup = {
    Unit.Description = "Majorlink: mail cleanup by his rules";
    Service = {
      Type = "oneshot";
      WorkingDirectory = "%h/valolink/majorlink";
      Environment = [
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
        "PATH=${pkgs.notmuch}/bin:${pkgs.libnotify}/bin"
      ];
      ExecStart = "${pkgs.nodejs}/bin/node --experimental-strip-types --no-warnings bin/mail-cleanup.ts run";
    };
  };
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
