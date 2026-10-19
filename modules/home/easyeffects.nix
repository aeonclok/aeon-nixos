# EasyEffects for the microphone (asusprime): "Notepad Mic 1" (the raw mono
# mic, modules/system/notepad-8fx.nix) goes through a voice chain and comes
# out as "Easy Effects Source", the processed input for calls, recordings and
# anything people listen to, and Majorlink's voice keys too: the compressor
# lifts quiet word ends, which helped dictation more than raw audio (the
# owner's choice, 19.10.2026). The raw mic stays as "Notepad Mic 1".
#
# Only the input is processed, and only from that mic: EasyEffects does not
# grab other apps' streams, and playback is left alone. Mod+A switches the
# effects off and on (global bypass); tune them by ear in the EasyEffects
# window, and copy what sounds right back into the preset below.
{ pkgs, lib, ... }:
let
  ee = "${pkgs.easyeffects}/bin/easyeffects";

  # Mod+A: effects on/off, with a notification saying which.
  toggle = pkgs.writeShellScriptBin "mic-effects-toggle" ''
    ${ee} --bypass-toggle >/dev/null 2>&1
    sleep 0.2
    if [ "$(${ee} -b 3 2>/dev/null | tr -d '[:space:]')" = 1 ]; then
      state="pois päältä (raaka mikki)"
    else
      state="päällä"
    fi
    ${pkgs.libnotify}/bin/notify-send -a EasyEffects -t 2000 \
      -h string:x-canonical-private-synchronous:mic-effects "Mikin efektit" "$state"
  '';
in
{
  home.packages = [ toggle ];

  # --load-preset at start did not take (19.10.2026: the chain stayed empty
  # until `easyeffects -l puhe` by hand), so the preset is loaded once the
  # daemon answers. A restart therefore brings back this file's settings;
  # tuning that should last belongs in the preset below.
  systemd.user.services.easyeffects.Service.ExecStartPost = "${pkgs.writeShellScript "easyeffects-load-puhe" ''
    for _ in $(seq 1 40); do
      ${ee} -l puhe >/dev/null 2>&1
      [ "$(${ee} -a input 2>/dev/null | tr -d '[:space:]')" = puhe ] && exit 0
      sleep 0.5
    done
    echo "easyeffects: could not load the puhe preset" >&2
  ''}";

  services.easyeffects = {
    enable = true;
    preset = "puhe";
    # A male speaking voice on a condenser up close, tuned by ear 19.10.2026
    # (every effect helps; the noise removal keeps word ends whole; the
    # de-esser is the least audible, kept anyway). Order: rumble out, noise out (before the compressor
    # raises it), tone, sibilance, evening out, a ceiling.
    extraPresets.puhe.input = {
      blocklist = [ ];
      plugins_order = [ "filter#0" "rnnoise#0" "filter#1" "filter#2" "deesser#0" "compressor#0" "limiter#0" ];
      # High-pass at 80 Hz, 24 dB/oct: rumble, desk knocks, traffic.
      "filter#0" = { type = "High-pass"; mode = "RLC (BT)"; slope = "x2"; frequency = 80.0; };
      # Background hiss of a high-gain preamp, the room.
      "rnnoise#0" = { use-standard-model = true; enable-vad = false; release = 20.0; wet = 0.0; };
      # Less boom: the proximity build-up of a low voice close to a condenser.
      "filter#1" = { type = "Bell"; mode = "RLC (BT)"; frequency = 250.0; gain = -3.0; quality = 1.0; };
      # Presence and clarity (+4 dB by ear; +2 was the start).
      "filter#2" = { type = "Bell"; mode = "RLC (BT)"; frequency = 4000.0; gain = 4.0; quality = 0.8; };
      # Sharp s sounds, which a condenser brings forward.
      "deesser#0" = { detection = "RMS"; threshold = -24.0; ratio = 3.0; f1-freq = 6000.0; f2-freq = 5000.0; f2-level = 12.0; };
      # Gentle evening out of loud and quiet speech.
      "compressor#0" = { mode = "Downward"; threshold = -24.0; ratio = 3.0; attack = 10.0; release = 120.0; knee = -6.0; makeup = 4.0; wet = 0.09; };
      # A ceiling for coughs and laughs.
      "limiter#0" = { threshold = -1.0; lookahead = 5.0; attack = 5.0; release = 20.0; gain-boost = false; };
    };
  };

  # EasyEffects writes this file itself, so only these keys are set, at each
  # switch: process the Notepad mic only, grab no app's stream, leave
  # playback alone.
  home.activation.easyeffectsMic = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rc="$HOME/.config/easyeffects/db/easyeffectsrc"
    mkdir -p "$(dirname "$rc")"
    touch "$rc"
    ${pkgs.crudini}/bin/crudini --ini-options=nospace --set "$rc" EffectsPipelines processAllInputs false
    ${pkgs.crudini}/bin/crudini --ini-options=nospace --set "$rc" EffectsPipelines processAllOutputs false
    ${pkgs.crudini}/bin/crudini --ini-options=nospace --set "$rc" StreamInputs useDefaultInputDevice false
    ${pkgs.crudini}/bin/crudini --ini-options=nospace --set "$rc" StreamInputs inputDevice notepad_mic1
  '';
}
