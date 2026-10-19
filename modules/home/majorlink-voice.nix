# Speaking to Majorlink (majorlink repo, MAJORLINK.md §2.1 step D): whisper.cpp
# with Vulkan for the Arc card, so bin/voice transcribes on this machine and
# audio never leaves it. The keys are in niriconf.kdl (Mod+Space, Mod+Shift+Space);
# Mod+Ctrl+Space and Mod+Alt+Space dictate; the Finnish model lives in ~/.local/share/majorlink/models.
{ pkgs, ... }:
{
  # wtype types dictation into the focused window (bin/voice --dictate).
  home.packages = [
    pkgs.whisper-cpp-vulkan
    pkgs.wtype
  ];
}
