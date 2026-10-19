# The Soundcraft Notepad-8FX as a microphone interface (asusprime).
#
# Its USB capture pair can carry the main mix (the factory default, with the
# computer's own playback in it, since the USB return is mixed in) or one of
# the input pairs taken after the gain knob, before EQ and the level knob. The
# Windows/Mac control panel switches it; on Linux it is one USB control
# message (reverse engineered by socranop, github.com/socratools/socranop).
# The mixer forgets the choice when it loses power, so it is sent again
# whenever the Notepad appears.
#
#   notepad-usb-source mic|3-4|5-6|mix    switch it by hand (no sudo)
#
# In mic mode the pair is Mic/Line 1 (left) and Mic/Line 2 (right, empty
# here), so PipeWire also gets a mono "Notepad Mic 1" input: the left channel
# alone, for Majorlink's voice keys and anything else that wants the mic. It
# is 6 dB louder than the stereo input, which averaged the voice with the
# empty channel. The USB signal is taken before channel 1's level knob, so
# that knob can sit at zero: the mic stays out of the speakers (no hearing
# yourself, no feedback) and the computer still gets all of it (tried
# 19.10.2026).
{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.pyusb ]);
  notepad-usb-source = pkgs.writeScriptBin "notepad-usb-source" ''
    #!${python}/bin/python3
    """Choose what the Notepad-8FX sends to the computer over USB."""
    import sys
    import usb.core

    SOURCES = {"mic": 0, "1-2": 0, "3-4": 1, "5-6": 2, "mix": 3}
    LABELS = {0: "Mic/Line 1 & 2", 1: "Stereo 3/4", 2: "Stereo 5/6", 3: "the main mix"}

    name = sys.argv[1] if len(sys.argv) > 1 else "mic"
    if name not in SOURCES:
        sys.exit(f"usage: notepad-usb-source {'|'.join(SOURCES)}")
    dev = usb.core.find(idVendor=0x05FC, idProduct=0x0031)
    if dev is None:
        sys.exit("No Notepad-8FX on USB.")
    source = SOURCES[name]
    dev.ctrl_transfer(0x40, 16, 0, 0, bytes([0, 0, 4, 0, source, 0, 0, 0]))
    print(f"Notepad-8FX USB input: {LABELS[source]}")
  '';
in
{
  environment.systemPackages = [ notepad-usb-source ];

  # The logged-in user may talk to the mixer (uaccess), and its arrival
  # starts the service below.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="05fc", ATTRS{idProduct}=="0031", TAG+="uaccess", TAG+="systemd", ENV{SYSTEMD_WANTS}+="notepad-usb-source.service"
  '';

  # The microphone alone over USB, set again on every plug-in and at boot.
  systemd.services.notepad-usb-source = {
    description = "Soundcraft Notepad-8FX: USB input from Mic/Line 1 & 2";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${notepad-usb-source}/bin/notepad-usb-source mic";
      # Not there (unplugged) is not a failure worth a red unit.
      SuccessExitStatus = [ 1 ];
    };
  };

  # "Notepad Mic 1": the left channel of the Notepad's capture pair as a mono
  # input.
  services.pipewire.extraConfig.pipewire."60-notepad-mic1" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "Notepad Mic 1";
          "capture.props" = {
            "node.name" = "capture.notepad_mic1";
            "audio.position" = [ "FL" ];
            "stream.dont-remix" = true;
            "target.object" = "alsa_input.usb-Soundcraft_Notepad-8FX-00.analog-stereo";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "notepad_mic1";
            "media.class" = "Audio/Source";
            "audio.position" = [ "MONO" ];
          };
        };
      }
    ];
  };
}
