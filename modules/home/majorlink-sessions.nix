# Majorlink's weekly check of the owner's work sessions (majorlink repo,
# MAJORLINK.md §13 step B): when Claude Code or opencode sessions are waiting
# to be gone through, it parks one EngineLink todo saying so. The going
# through itself happens with the copilot (read_work_sessions, log_work_batch).
# Claude Code keeps transcripts 365 days (cleanupPeriodDays), so a missed run
# loses nothing; Persistent catches up after the machine was off.
{ pkgs, ... }:
{
  systemd.user.services.majorlink-work-sessions = {
    Unit = {
      Description = "Majorlink: weekly check of unhandled work sessions";
      StartLimitIntervalSec = "6h";
      StartLimitBurst = 6;
    };
    Service = {
      Type = "oneshot";
      WorkingDirectory = "%h/valolink/majorlink";
      ExecStart = "${pkgs.nodejs}/bin/node --experimental-strip-types --no-warnings bin/work-sessions.ts --notify";
      Environment = "PATH=${pkgs.git}/bin";
      # EngineLink or the network down at the catch-up run: try again rather
      # than lose the week (review, 18.10.2026).
      Restart = "on-failure";
      RestartSec = "30min";
    };
  };
  systemd.user.timers.majorlink-work-sessions = {
    Unit.Description = "Majorlink: weekly check of unhandled work sessions";
    Timer = {
      OnCalendar = "Mon *-*-* 08:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
