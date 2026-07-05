{ pkgs, ... }:
{
  # TUI mail/calendar trial (2026-07): Herald vs aerc+notmuch, side by side.
  home.packages = [
    (import ./herald.nix { inherit pkgs; })
  ];

  # Pipeline: lieer syncs Gmail (API, keeps labels as tags) into the maildir
  # and feeds notmuch directly; aerc reads the notmuch database; sending goes
  # back out through the Gmail API via `gmi send`.
  programs.aerc.enable = true;
  programs.notmuch.enable = true;
  programs.lieer.enable = true;
  services.lieer.enable = true; # systemd timer running `gmi sync` per account

  accounts.email.maildirBasePath = "Maildir";
  accounts.email.accounts.valolink = {
    primary = true;
    address = "reima.kokko@valolink.fi";
    userName = "reima.kokko@valolink.fi";
    realName = "Reima Kokko";
    flavor = "gmail.com";

    notmuch.enable = true;
    lieer = {
      enable = true;
      sync = {
        enable = true;
        frequency = "*:0/5"; # sync every 5 minutes
      };
    };

    aerc = {
      enable = true;
      extraAccounts = {
        source = "notmuch://~/Maildir";
        outgoing = "exec:gmi send -t --quiet -C ~/Maildir/valolink";
        default = "INBOX";
        query-map = "~/.config/aerc/queries.conf";
        # Gmail stores sent mail itself when sending via the API
        copy-to = "";
        cache-headers = true;
      };
    };
  };

  # Virtual folders for aerc's notmuch backend (notmuch tag queries)
  xdg.configFile."aerc/queries.conf".text = ''
    INBOX=tag:inbox
    Starred=tag:flagged
    Sent=tag:sent
    Drafts=tag:draft
    Archive=not tag:inbox and not tag:trash and not tag:spam
    Trash=tag:trash
  '';
}
