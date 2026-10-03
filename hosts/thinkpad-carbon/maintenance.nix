# "maintenance" boot menu entry: boots the normal system's initrd but stops in
# a root emergency shell *before* / is mounted, so offline-only disk work (like
# shrinking the ext4 root) can be done without a live USB.
#
# Step 1 of the LUKS migration: shrink nvme0n1p3 so an encrypted partition fits
# after it. In the shell: `cat /README.txt`, then `shrink-root`.
#
# Only this specialisation's initrd gets the passwordless shell; normal boot
# entries are unchanged.
{ pkgs, ... }:
let
  sr = import ./shrink-root.nix {
    inherit pkgs;
    disk = "/dev/nvme0n1";
    part = "/dev/nvme0n1p3";
    partNo = "3";
    # Safety checks: the partition must still be exactly the one we measured.
    rootUuid = "ad404114-77c4-430c-8160-b420fec26e72";
    partStart = "44042240"; # sectors
    origSectors = "956172288"; # 455 GiB, the size before shrinking
    # Filesystem goes to 120 GiB first, partition to 130 GiB, then the filesystem
    # grows back to fill the partition: a mistyped number can't cut into data.
    fsGiB = "120";
    partGiB = "130";
  };
in
{
  specialisation.maintenance.configuration = {
    system.nixos.tags = [ "maintenance" ];
    boot.kernelParams = [ "rd.systemd.unit=emergency.target" ];
    boot.initrd.systemd = {
      emergencyAccess = true;
      # The initrd builder follows ELF library deps but not a script's text
      # references, so shrink-root's tools must be listed here too
      # (which also puts them on the shell's PATH for manual use).
      initrdBin = [ sr.shrink-root ] ++ sr.tools;
      contents."/README.txt".source = sr.readme;
    };
  };
}
