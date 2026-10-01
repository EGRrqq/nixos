{ self, inputs, ... }:
{
  flake.nixosModules.storage = { pkgs, lib, ... }: {
    # Second drive, a small ssd that was empty. It is formatted with btrfs and
    # holds projects, renders and other things that are expensive to redo, so
    # it gets a snapshot every month.
    #
    # Snapshots only cover mistakes, a deleted folder or a project that stopped
    # opening. They are not a backup, if the drive dies they die with it. A copy
    # on the big external drive is what covers that.
    fileSystems."/mnt/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        # Without this a missing or unformatted drive stops the boot
        "nofail"
      ];
    };

    # The root of a fresh btrfs belongs to root, the user has to own it to put
    # anything there without sudo. There is no group named egr, the primary
    # group is users
    systemd.tmpfiles.rules = [
      "d /mnt/data 0755 egr users - -"
    ];

    # Keep the newest snapshots and drop the rest, otherwise they pile up and
    # fill the drive.
    #
    # The snapshot destination has to be a btrfs subvolume, not a plain
    # directory. A nested subvolume is left out when its parent is snapshotted,
    # so every snapshot holds only the data. A plain directory would make each
    # new snapshot contain all the older ones and the drive would fill up on its
    # own.
    systemd.services.storage-snapshot = {
      description = "Monthly snapshot of /mnt/data";
      path = [
        pkgs.coreutils
        pkgs.btrfs-progs
      ];
      script = ''
        if ! btrfs subvolume show /mnt/data/.snapshots >/dev/null 2>&1; then
          echo "/mnt/data/.snapshots is not a subvolume, refusing to snapshot" >&2
          echo "create it with: sudo btrfs subvolume create /mnt/data/.snapshots" >&2
          exit 1
        fi

        btrfs subvolume snapshot -r /mnt/data /mnt/data/.snapshots/$(date -I)

        btrfs subvolume list -o /mnt/data/.snapshots \
          | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' \
          | sort -r \
          | tail -n +13 \
          | while read -r old; do
              btrfs subvolume delete "/mnt/data/.snapshots/$old"
            done
      '';
      serviceConfig = {
        Type = "oneshot";
        Nice = "10";
      };
    };

    systemd.timers.storage-snapshot = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # First day of every month
        OnCalendar = "*-*-01 04:00:00";
        # Catch up on a snapshot that was missed while the machine was off
        Persistent = true;
      };
    };
  };
}