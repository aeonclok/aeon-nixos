{ ... }:
{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/fish.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/foot.nix
    ../../modules/home/waybar.nix
    ../../modules/home/tmux.nix
    ../../modules/home/mail.nix
    ../../modules/home/laya-mail.nix # mail triage model + automatic triage (asusprime only)
    ../../modules/home/majorlink-sessions.nix # weekly check of work sessions waiting for Majorlink (asusprime only)
    ../../modules/home/majorlink-voice.nix # speech to text for Majorlink on the Arc card (asusprime only)
    ../../modules/home/majorlink-mail.nix # pairs Majorlink's mail drafts with what was sent (asusprime only)
    ../../modules/home/majorlink-phone.nix # the phone app's gateway over Tailscale (asusprime only)
    ../../modules/home/easyeffects.nix # voice effects for the Notepad mic, Mod+A on/off (asusprime only)
  ];

  home = {
    username = "reima";
    homeDirectory = "/home/reima";
    stateVersion = "25.05";
  };
}
