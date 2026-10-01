{ self, inputs, ... }:
{
  flake.nixosModules.storage = { pkgs, lib, ... }: {
    # Second drive, a small ssd that is empty. It is formatted with btrfs and
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

    # Keep the newest snapshots and drop the rest, otherwise they pile up and
    # fill the drive.
    systemd.services.storage-snapshot = {
      description = "Monthly snapshot of /mnt/data";
      path = [
        pkgs.coreutils
        pkgs.btrfs-progs
      ];
      script = ''
        mkdir -p /mnt/data/.snapshots
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