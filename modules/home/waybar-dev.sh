#!/usr/bin/env bash

FLAKE_DIR="$HOME/nix"

CONFIG_PATH="nixosConfigurations.\"$(hostname)\".config.home-manager.users.\"$(whoami)\""

TMP_CONFIG="/tmp/waybar-preview-config.json"
TMP_STYLE="/tmp/waybar-preview-style.css"

pkill waybar

nix eval --json --extra-experimental-features "nix-command flakes" "${FLAKE_DIR}#${CONFIG_PATH}.programs.waybar.settings" | jq '[.[]] | del(..|nulls)' >"$TMP_CONFIG"

if [ $? -ne 0 ]; then
  echo "❌ Failed to extract settings. Check your FLAKE_DIR and CONFIG_PATH."
  exit 1
fi

nix eval --raw --extra-experimental-features "nix-command flakes" \
  "${FLAKE_DIR}#${CONFIG_PATH}.programs.waybar.style" \
  >"$TMP_STYLE"

if [ $? -ne 0 ]; then
  echo "❌ Failed to extract style. Check your FLAKE_DIR and CONFIG_PATH."
  exit 1
fi

echo "Config generated at $TMP_CONFIG"
echo "Style generated at $TMP_STYLE"

echo "waybar -c $TMP_CONFIG -s $TMP_STYLE"

waybar -c "$TMP_CONFIG" -s "$TMP_STYLE"
# waybar -c "$TMP_CONFIG" &
