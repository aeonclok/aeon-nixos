# shrink-root: offline shrink of an ext4 partition (fs -> fsGiB, partition ->
# partGiB, fs grows to fill), with safety checks, plus the README shown in the
# maintenance shell. Parameterised so the VM test can aim it at a scratch disk.
{
  pkgs,
  disk,
  part,
  partNo,
  rootUuid,
  partStart,
  origSectors,
  fsGiB,
  partGiB,
}:
let
  tools = with pkgs; [
    coreutils
    e2fsprogs
    gnugrep
    util-linux
  ];

  shrink-root = pkgs.writeShellApplication {
    name = "shrink-root";
    runtimeInputs = tools;
    text = ''
      DISK=${disk} PART=${part} PARTNO=${partNo}
      SYS=/sys/class/block/''${PART##*/}
      FS_BYTES=$(( ${fsGiB} * 1024 * 1024 * 1024 ))
      PART_SECTORS=$(( ${partGiB} * 1024 * 1024 * 2 ))

      die() { echo; echo "ABORT: $*" >&2; echo "Nothing after this point was done." >&2; exit 1; }
      step() { echo; echo "==> $*"; }
      fs_field() { dumpe2fs -h "$PART" 2>/dev/null | grep "^$1:" | grep -oE '[0-9]+$'; }

      step "Safety checks"
      [ -e /etc/initrd-release ] || die "not in the initrd maintenance shell"
      [ -b "$PART" ] || die "$PART does not exist"
      [ "$(blkid -s UUID -o value "$PART")" = "${rootUuid}" ] || die "$PART is not the expected root filesystem (UUID mismatch)"
      [ "$(blkid -s TYPE -o value "$PART")" = ext4 ] || die "$PART is not ext4"
      ! grep -q "^$PART " /proc/mounts || die "$PART is mounted"
      [ "$(cat "$SYS/start")" = "${partStart}" ] || die "partition start sector changed"
      CUR_SECTORS=$(cat "$SYS/size")
      [ "$CUR_SECTORS" -gt "$PART_SECTORS" ] || die "partition is already ${partGiB} GiB or smaller (already shrunk?)"
      echo "ok: $PART, ext4, unmounted, $(( CUR_SECTORS / 2 / 1024 / 1024 )) GiB"

      step "Checking the filesystem (e2fsck -f -p)"
      rc=0; e2fsck -f -p "$PART" || rc=$?
      [ "$rc" -lt 4 ] || die "e2fsck found errors it could not fix (exit $rc); run 'e2fsck -f $PART' by hand"

      step "Checking that the data fits in ${fsGiB} GiB"
      BS=$(fs_field "Block size")
      MIN_BLOCKS=$(resize2fs -P "$PART" 2>/dev/null | grep -oE '[0-9]+$')
      MIN_BYTES=$(( MIN_BLOCKS * BS ))
      echo "minimum filesystem size: $(( MIN_BYTES / 1024 / 1024 / 1024 )) GiB, target ${fsGiB} GiB"
      [ $(( MIN_BYTES + 10 * 1024 * 1024 * 1024 )) -lt "$FS_BYTES" ] || die "less than 10 GiB headroom at ${fsGiB} GiB; free some space or raise fsGiB in maintenance.nix"

      echo
      echo "About to: shrink the filesystem to ${fsGiB} GiB, shrink partition $PARTNO to ${partGiB} GiB,"
      echo "then grow the filesystem to fill the partition. Takes a few minutes."
      read -r -p "Type SHRINK to continue: " answer
      [ "$answer" = SHRINK ] || die "not confirmed"

      step "1/3 Shrinking the filesystem to ${fsGiB} GiB"
      resize2fs -p "$PART" ${fsGiB}G
      FS_NOW=$(( $(fs_field "Block count") * BS ))
      [ "$FS_NOW" -le "$FS_BYTES" ] || die "filesystem is still $FS_NOW bytes; NOT touching the partition"

      step "2/3 Shrinking partition $PARTNO to ${partGiB} GiB (start sector unchanged)"
      echo ",$PART_SECTORS" | sfdisk --no-reread --wipe-partitions never -N "$PARTNO" "$DISK"
      partx -u --nr "$PARTNO" "$DISK"
      [ "$(cat "$SYS/size")" = "$PART_SECTORS" ] || die "kernel still sees the old partition size; reboot into maintenance and run 'resize2fs $PART'"

      step "3/3 Growing the filesystem to fill the partition"
      resize2fs -p "$PART"

      step "Final read-only check"
      e2fsck -f -n "$PART" || die "final check reported problems; do NOT reboot normally, see README.txt"

      echo
      echo "Done. $PART is now ${partGiB} GiB; the free space after it is for the encrypted partition."
      echo "Reboot into the normal entry with: systemctl reboot"
    '';
  };

  readme = pkgs.writeText "README.txt" ''
    MAINTENANCE SHELL (thinkpad-carbon)
    ===================================
    You're in the initrd, before / is mounted. Nothing on disk is in use.
    Leave any time with:  systemctl reboot   (then pick the normal entry)

    STEP 1 OF THE LUKS MIGRATION: shrink the root partition
    -------------------------------------------------------
    Run:

        shrink-root

    It checks it's the right partition (UUID, start sector, ext4, unmounted),
    runs e2fsck, checks the data fits, asks you to type SHRINK, then:
      1. resize2fs ${part} ${fsGiB}G           (filesystem -> ${fsGiB} GiB)
      2. sfdisk -N ${partNo}: partition -> ${partGiB} GiB    (start unchanged)
      3. resize2fs ${part}                (filesystem grows to fill it)
    and a final read-only e2fsck. If any check fails it stops and says so.

    When it prints "Done":  systemctl reboot

    IF SOMETHING GOES WRONG
    -----------------------
    * shrink-root stopped with ABORT before step 2: the partition is untouched.
      Rebooting normally is fine (a smaller filesystem in a big partition
      works). To grow it back (resize2fs refuses without a fresh e2fsck):
        e2fsck -f -p ${part}
        resize2fs ${part}

    * Need the partition back at its original size (start never moves):
        echo ',${origSectors}' | sfdisk --no-reread -N ${partNo} ${disk}
        partx -u --nr ${partNo} ${disk}
        e2fsck -f -p ${part}
        resize2fs ${part}

    * Filesystem check complaints:  e2fsck -f ${part}   (interactive, answer y)

    Original layout (512-byte sectors):
      p1 ESP   start 2048      size 2097152    (1 GiB)
      p2 swap  start 2099200   size 41943040   (20 GiB)
      p3 root  start ${partStart}  size ${origSectors}  (455 GiB)  UUID ${rootUuid}

    Before running: make sure the restic backup (gdrive:backups/restic/
    thinkpad-carbon) is fresh and /home/reima is rsynced to asusprime.
  '';
in
{
  inherit tools shrink-root readme;
}
