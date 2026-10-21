{ pkgs }:

# Keeps an appended log (a service's StandardOutput=append:) from growing forever:
# past 10 MB only the newest 5 MB stay, cut at a line start. Rewritten in place
# rather than replaced, so a running `tail -f` keeps following it. Run it as the
# first ExecStartPre, before anything of that run is written.
pkgs.writeShellScript "cap-log" ''
  export PATH=${pkgs.coreutils}/bin
  f=$1
  [ -f "$f" ] && [ "$(stat -c %s "$f")" -gt 10000000 ] || exit 0
  t=$(mktemp)
  tail -c 5000000 "$f" | tail -n +2 > "$t"
  cat "$t" > "$f"
  rm -f "$t"
''
