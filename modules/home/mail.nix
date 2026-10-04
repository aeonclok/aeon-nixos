{ pkgs, ... }:
let
  # Experiment: render an HTML part with w3m + sixel images in its own wezterm
  # window (aerc's embedded terminal drops sixel). Network is allowed, so
  # remote images — tracking pixels included — get loaded. Runs w3m directly
  # with the options of aerc's `html` filter: the packaged `html-unsafe` still
  # isolates the network, because nixpkgs' wrapper hides the name it checks.
  aerc-html-images = pkgs.writeShellScript "aerc-html-images" ''
    f=$(mktemp --suffix=.html)
    cat > "$f"
    exec ${pkgs.wezterm}/bin/wezterm start -- sh -c '
      PATH=${pkgs.libsixel}/bin:$PATH ${pkgs.w3m}/bin/w3m \
        -I UTF-8 -O UTF-8 -T text/html -s -graph \
        -o fold_textarea=true -o fold_line=true \
        -o decode_url=true -o display_link=true -o display_borders=true \
        -o display_image=true -o auto_image=true -sixel "$1"
      rm -f "$1"' _ "$f"
  '';
in
{
  # TUI mail/calendar trial (2026-07): Herald vs aerc+notmuch, side by side.
  home.packages = [
    (import ./herald.nix { inherit pkgs; })
  ];

  # Pipeline: lieer syncs Gmail (API, keeps labels as tags) into the maildir
  # and feeds notmuch directly; aerc reads the notmuch database; sending goes
  # back out through the Gmail API via `gmi send`.
  programs.aerc = {
    enable = true;
    # accounts.conf is a read-only store symlink; it holds no secrets (auth
    # lives in lieer's credentials file), so skip aerc's permission check.
    extraConfig.general.unsafe-accounts-conf = true;
    # aerc saves HTML parts as *.ehtml and mail HTML is usually a fragment, so
    # xdg-open sniffs it as text/plain (→ nvim) and Firefox wouldn't render
    # the extension anyway. Copy to .html and open it in Firefox directly, in a
    # new window so niri focuses it (a tab in an existing window stays hidden).
    extraConfig.openers."text/html" = "cp {} {}.html && firefox --new-window {}.html";
    # Setting binds makes HM write binds.conf from scratch, so start from
    # aerc's shipped defaults and splice extra keys into [view].
    # `e` shows the current part in nvim in an aerc tab (:q returns);
    # `o` still hands it to xdg-open (Firefox for HTML).
    extraBinds =
      builtins.replaceStrings
        [ "[view]\n" ]
        [
          (
            "[view]\n"
            + "e = :pipe nvim -R +'set nomodified' -<Enter>\n"
            + "I = :pipe -b ${aerc-html-images}<Enter>\n"
          )
        ]
        (builtins.readFile "${pkgs.aerc}/share/aerc/binds.conf");
    # HM's aerc.conf replaces aerc's defaults, so parts have no viewer unless
    # filters are set. These are aerc's bundled filters (html renders via
    # w3m with network access blocked); `:open` on a part opens it in the
    # browser instead.
    extraConfig.filters = {
      "text/plain" = "colorize";
      "text/html" = "! html";
      "text/calendar" = "calendar";
      "message/delivery-status" = "colorize";
      "message/rfc822" = "colorize";
      ".headers" = "colorize";
    };
    # Written by hand instead of via accounts.email.accounts.<name>.aerc: the
    # HM generator emits options newer aerc deprecates (maildir-store and a
    # database path in the notmuch URL; the db is found via NOTMUCH_CONFIG).
    extraAccounts.valolink = {
      source = "notmuch://";
      maildir-account-path = "valolink";
      outgoing = "exec:gmi send -t --quiet -C ~/Maildir/valolink";
      from = "Reima Kokko <reima.kokko@valolink.fi>";
      default = "INBOX";
      postpone = "Drafts";
      query-map = "~/.config/aerc/queries.conf";
      # Gmail stores sent mail itself when sending via the API
      copy-to = "";
      cache-headers = true;
    };
  };
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
      # Only a partial history is pulled locally (gmi pull --limit), which
      # lieer refuses to do while it would delete everything not fetched.
      settings.remove_local_messages = false;
      sync = {
        enable = true;
        frequency = "*:0/5"; # sync every 5 minutes
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
