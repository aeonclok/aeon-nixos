{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/fonts.nix
    ../../modules/system/base.nix
    ../../modules/system/syncthing.nix
  ];
  networking.hostName = "asusprime";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 3030 ];

  system.stateVersion = "25.05";

  # 1. Enable Intel Graphics Compute Drivers (Level Zero & Vulkan)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime # Crucial for Intel AI compute
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Rootless podman for project dev shells (e.g. ~/valolink/odysseus).
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    # `docker` CLI alias + docker.sock compatibility for tools that expect Docker.
    dockerCompat = true;
    # Compose containers resolve each other by service name (odysseus -> chromadb).
    defaultNetwork.settings.dns_enabled = true;
  };

  # 2. Local LLM Background Service
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan; # Forces the Vulkan-compatible binary
    environmentVariables = {
      # Optimizes Intel Arc command queueing for faster inference
      SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS = "1";
      # Ensures Ollama targets the dedicated GPU, not an integrated one
      ONEAPI_DEVICE_SELECTOR = "level_zero:0";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  powerManagement.enable = true;

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0CF1-8E41";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}
