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
    # Sidebar: label folders named prefix/name (src/*, tag/*) are shown as an indented tree.
    extraConfig.ui.dirlist-tree = true;
    # aerc saves HTML parts as *.ehtml and mail HTML is usually a fragment, so
    # xdg-open sniffs it as text/plain (→ nvim) and Firefox wouldn't render
    # the extension anyway. Copy to .html and open it in Firefox directly, in a
    # new window so niri focuses it (a tab in an existing window stays hidden).
    extraConfig.openers."text/html" = "cp {} {}.html && firefox --new-window {}.html";
    # Setting binds makes HM write binds.conf from scratch, so start from
    # aerc's shipped defaults and splice extra keys into [view].
    # `e` shows the current part in nvim in an aerc tab (:q returns);
    # `o` still hands it to xdg-open (Firefox for HTML).
    # The [messages] keys are the triage review loop: one key per verdict on the
    # selected mail, each one also adds `reviewed` and moves on. `y` keeps the
    # script's pre-filled tags. None of these keys is bound by aerc's defaults
    # (p/r/R/t/z are chord prefixes there, n/v/s/b are taken).
    extraBinds =
      builtins.replaceStrings
        [ "[view]\n" "[messages]\n" ]
        [
          (
            "[view]\n"
            + "e = :pipe nvim -R +'set nomodified' -<Enter>\n"
            + "I = :pipe -b ${aerc-html-images}<Enter>\n"
          )
          (
            "[messages]\n"
            + "y = :modify-labels +reviewed<Enter>:next<Enter>\n"
            # 1-4 toggle a label on the selected mail without moving on; y then confirms.
            + "1 = :modify-labels !needs-reply<Enter>\n"
            + "2 = :modify-labels !needs-action<Enter>\n"
            # 3/4/5 answer the commercial question; lead and pitch exclude each other.
            + "3 = :modify-labels +lead -pitch<Enter>\n"
            + "4 = :modify-labels +pitch -lead<Enter>\n"
            + "5 = :modify-labels -lead -pitch<Enter>\n"
            # i shows the model's reasons for the selected mail; x closes a todo item.
            + "i = :pipe -m laya-why<Enter>\n"
            + "x = :modify-labels -needs-reply -needs-action +done<Enter>:next<Enter>\n"
            + "w = :modify-labels +ctx/work -ctx/personal +reviewed<Enter>:next<Enter>\n"
            + "o = :modify-labels +ctx/personal -ctx/work +reviewed<Enter>:next<Enter>\n"
            + "h = :modify-labels +src/human -src/form -src/server -src/wordpress -src/newsletter -src/service +reviewed<Enter>:next<Enter>\n"
            + "f = :modify-labels +src/form -src/human -src/server -src/wordpress -src/newsletter -src/service +reviewed<Enter>:next<Enter>\n"
            + "l = :modify-labels +src/newsletter -src/human -src/form -src/server -src/wordpress -src/service +reviewed<Enter>:next<Enter>\n"
            + "e = :modify-labels +src/service -src/human -src/form -src/server -src/wordpress -src/newsletter +reviewed<Enter>:next<Enter>\n"
            + "u = :modify-labels +guess/unsure +reviewed<Enter>:next<Enter>\n"
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
      # Daily folders first in this order, the label trees (src/*, tag/*) after them. `mail` is the raw
      # maildir (= All Mail, its count is every unread mail); reviewed/waiting/leads-mine are bookkeeping.
      folders-sort = "INBOX,focus,todo,leads,review-v2,alerts,automated,Sent,Drafts,Starred,Archive,Trash";
      folders-exclude = "mail,reviewed,waiting,leads-mine";
    };
  };
  programs.notmuch = {
    enable = true;
    # lieer owns the tags (Gmail labels <-> notmuch tags) and stores files
    # without maildir flags, so flag sync would read every mail as unread, and
    # a stray `notmuch new` must not stamp unread+inbox on everything.
    new.tags = [ "new" ];
    maildir.synchronizeFlags = false;
  };
  programs.lieer.enable = true;
  services.lieer.enable = true; # systemd timer running `gmi sync` per account
  # Keep every sync's output in a plain log next to the journal, with start/end
  # markers, so a sync can be followed with `tail -f ~/.local/state/lieer-valolink.log`.
  systemd.user.services.lieer-valolink.Service = {
    StandardOutput = "append:%h/.local/state/lieer-valolink.log";
    StandardError = "append:%h/.local/state/lieer-valolink.log";
    ExecStartPre = "${pkgs.coreutils}/bin/date '+=== %%F %%T sync start ==='";
    ExecStopPost = "${pkgs.coreutils}/bin/date '+=== %%F %%T sync end ==='";
  };

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
      # Triage review tags stay local: lieer never turns these into Gmail
      # labels. The final tags (src/*, ctx/*, alert, report, receipt,
      # needs-reply, fyi, triaged) are not listed, so they do sync.
      settings.ignore_tags = [
        "reviewed"
        "guess/ctx-work"
        "guess/ctx-personal"
        "guess/src-human"
        "guess/src-form"
        "guess/src-server"
        "guess/src-wordpress"
        "guess/src-newsletter"
        "guess/src-service"
        "guess/needs-reply"
        "guess/fyi"
        "guess/alert"
        "guess/report"
        "guess/receipt"
        "guess/unsure"
        "guess/needs-action"
        "guess/lead"
        "guess/pitch"
        "guess/v2"
      ];
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
    review-v2=tag:guess/v2 and not tag:reviewed
    reviewed=tag:reviewed
    todo=(tag:needs-reply or tag:needs-action) and not tag:pitch and not tag:replied and not tag:done
    leads=tag:lead and not tag:done
    leads-mine=tag:lead and not tag:src/form and not tag:done
    waiting=tag:waiting and not tag:done
    alerts=tag:alert and date:3d..
    focus=tag:inbox and not tag:sent and (not tag:triaged or tag:src/human or tag:src/form or tag:src/unsure or tag:alert or tag:lead or tag:needs-reply or tag:needs-action)
    automated=tag:inbox and not tag:alert and (tag:src/newsletter or tag:src/service or tag:src/wordpress or tag:src/server or tag:report)
    src/human=tag:src/human
    src/form=tag:src/form
    src/unsure=tag:src/unsure
    src/newsletter=tag:src/newsletter
    src/service=tag:src/service
    src/wordpress=tag:src/wordpress
    src/server=tag:src/server
    tag/report=tag:report
    tag/receipt=tag:receipt
    tag/needs-reply=tag:needs-reply
    tag/needs-action=tag:needs-action
    tag/fyi=tag:fyi
    tag/pitch=tag:pitch
  '';
}
