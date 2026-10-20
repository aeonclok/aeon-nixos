# asusprime only: the Laya mail model (podman container `laya-mail`, :8000), automatic triage of new mail
# after each lieer sync, and a Waybar indicator. Script, data and models live in ~/.local/share/laya
# (real customer mail, never in git); see ~/.local/share/laya/HANDOFF.md.
{ pkgs, lib, ... }:
let
  # Waybar: robot icon, red with "off" when the model server does not answer; the number is mail from
  # the last 7 days that triage has not reached yet (normally none).
  status = pkgs.writeShellScript "laya-mail-status" ''
    code=$(${pkgs.curl}/bin/curl -s -m 2 -o /dev/null -w '%{http_code}' http://127.0.0.1:8000/health)
    waiting=$(NOTMUCH_CONFIG=$HOME/.config/notmuch/default/config ${pkgs.notmuch}/bin/notmuch count 'not tag:triaged and date:7d..' 2>/dev/null || echo "?")
    last=$(${pkgs.gnugrep}/bin/grep -a 'triage start' "$HOME/.local/state/mail-triage.log" 2>/dev/null | tail -1 | cut -d' ' -f2-3)
    if [ "$code" = 200 ]; then class=up; text="󰚩"; else class=down; text="󰚩 off"; fi
    [ "$waiting" != 0 ] && text="$text $waiting"
    printf '{"text": "%s", "class": "%s", "tooltip": "laya-mail: %s\\nuntriaged mail (7 d): %s\\nlast triage: %s\\nclick: restart laya-mail"}\n' \
      "$text" "$class" "$class" "$waiting" "''${last:-never}"
  '';
in
{
  # Start the existing container at login (it is created once with `podman run`, see HANDOFF.md;
  # recreate it to change the model). `podman start` on a running container is a no-op.
  systemd.user.services.laya-mail = {
    Unit.Description = "Laya mail model server (podman container laya-mail on :8000)";
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "PATH=/run/wrappers/bin:${pkgs.podman}/bin";
      ExecStart = "${pkgs.podman}/bin/podman start laya-mail";
      ExecStop = "${pkgs.podman}/bin/podman stop laya-mail";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # After every successful sync, triage new mail: rules first, the model for the rest; tags go to Gmail
  # on the next sync. Drafts are left alone: Majorlink's drafts come down from Gmail untriaged. If the model server is down, mail that needs it stays untriaged for a later run.
  systemd.user.services.lieer-valolink.Unit.OnSuccess = [ "mail-triage.service" ];
  systemd.user.services.mail-triage = {
    Unit.Description = "Triage new mail after a lieer sync";
    Service = {
      Type = "oneshot";
      Environment = [
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
        "PATH=${pkgs.notmuch}/bin:${pkgs.coreutils}/bin"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/date '+=== %%F %%T triage start ==='";
      ExecStart = "${pkgs.python3}/bin/python3 %h/.local/share/laya/mail/triage.py --apply --summary --query 'not tag:triaged and not tag:draft and date:7d..'";
      StandardOutput = "append:%h/.local/state/mail-triage.log";
      StandardError = "append:%h/.local/state/mail-triage.log";
    };
  };

  # Morning digest (prototype): new person mail summarised by a local LLM (Ollama, Poro 2 8B on the Arc)
  # into ~/.local/state/mail-digest/YYYY-MM-DD.md (+ latest.md), plus a desktop notification.
  # Persistent = run at the next start if the machine was off at 06:30.
  systemd.user.services.mail-digest = {
    Unit.Description = "Morning digest of new mail";
    # after a catch-up tori run at boot, so the digest gets today's summary.json
    Unit.After = [ "tori-watch.service" ];
    Service = {
      Type = "oneshot";
      Environment = [
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
        "PATH=${pkgs.notmuch}/bin:${pkgs.coreutils}/bin:${pkgs.libnotify}/bin"
      ];
      ExecStart = "${pkgs.python3}/bin/python3 %h/.local/share/laya/mail/digest.py";
    };
  };
  systemd.user.timers.mail-digest = {
    Unit.Description = "Morning digest of new mail at 06:30";
    Timer = {
      OnCalendar = "*-*-* 06:30";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Daily tori.fi watch for LLM hardware (used GPUs / PCs with ≥16 GB VRAM under the half-of-new price rule):
  # crawls the newest listings, re-checks the shortlist, records sold ones for price insight. Writes
  # ~/.local/state/tori-watch/YYYY-MM-DD.md (+ latest.md, summary.json for the morning digest).
  # No mail, no notification; script and price table in ~/.local/share/laya/tori-watch.
  systemd.user.services.tori-watch = {
    Unit.Description = "Daily tori.fi watch for LLM hardware";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${pkgs.coreutils}/bin";
      TimeoutStartSec = "1h";
      ExecStartPre = "${pkgs.coreutils}/bin/date '+=== %%F %%T tori-watch start ==='";
      ExecStart = "${pkgs.python3}/bin/python3 %h/.local/share/laya/tori-watch/toriwatch.py";
      StandardOutput = "append:%h/.local/state/tori-watch/run.log";
      StandardError = "append:%h/.local/state/tori-watch/run.log";
    };
  };
  systemd.user.timers.tori-watch = {
    Unit.Description = "tori.fi watch daily at 05:45, before the morning digest";
    Timer = {
      OnCalendar = "*-*-* 05:45";
      RandomizedDelaySec = "5m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  programs.waybar.settings.mainBar = {
    modules-right = [ "custom/laya" ];
    "custom/laya" = {
      exec = "${status}";
      return-type = "json";
      interval = 30;
      on-click = "systemctl --user restart laya-mail.service";
    };
  };
  programs.waybar.style = lib.mkAfter ''
    #custom-laya {
      padding: 0 10px;
    }
    #custom-laya.down {
      color: @base08;
    }
  '';
}
