# History

Chat work log, newest at the bottom.

## wrapper-modules removal

Explained and confirmed dead. With niri and noctalia having their own configs,
nothing was injecting into them any more. Not restored.

## niri important hotkeys

Read the overlay code to see what is configurable. Titles come from
`hotkey-overlay-title`, groups from `action`, unlisted actions can be hidden
with `hide-not-bound`. Font is hardcoded, so no zoom option exists.

The user picked titles only. Ten of them added for terminal, yazi, Telegram,
Brave, Obsidian, launcher, lock and Pomodoro. First attempt was missing `=`
and the file did not validate, fixed. `niri validate` passes.

Commit `b776f06` in `~/.config/niri`, pushed.

## niri typing

`repeat-delay 200 -> 250`, `repeat-rate 35 -> 32`, because the old values
produced doubled symbols. Added `options "grp:win_space_toggle"` for
Super/Space to switch us/ru.

Commit `47b7e4d`, pushed. Note: the diff also contained
`hotkey-overlay { skip-at-startup }` and a trailing newline fix. The user later
confirmed the overlay block was their own change, so it was kept.

## Cloud storage

Researched the actual nixpkgs situation and corrected an earlier wrong
assumption: there is no `gvfs-backends`, `gvfsd-dav` ships inside
`pkgs.gvfs`. And `gio` lives in `lib.getBin pkgs.glib`, not in `pkgs.glib`.

Added to `modules/home-manager/_fragments/packages.nix`: `rclone` and
`(lib.getBin glib)`. Added the same glib bin output to `extraPackages` of the
yazi wrapper in `_fragments/yazi.nix`, so the yazi gvfs plugin can actually
run `gio`. Created `modules/features/srv-gvfs.nix` enabling `services.gvfs`
with `gvfs` and `gio` in system packages, imported into the blob host.

Verified in the built system closure that `gio` is present and the yazi wrapper
references both `glib-bin` and `gvfs`. Confirmed `gvfsd-dav` and `gvfsd-http`
exist in the gvfs output. `gvfs-mount` is intentionally absent from the system
profile, gvfs is activated over D-Bus instead.

## libvirt

Created `modules/features/srv-libvirt.nix`: libvirtd, virt-manager,
virt-viewer, qemu with KVM, qemu-utils, OVMFFull, swtpm, spice-vdagentd and
SPICE USB redirection. Added `egr` to `libvirtd`, `kvm`, `input` and `disk`.

This also gives disk access to `/dev/sdb` after a rebuild.

## laptop host

Created `modules/laptop-host/` with `default.nix`, `configuration.nix` and
`hardware-configuration.nix`. New `hw-graphics-laptop.nix` for Intel-only
modesetting, new `hw-thermald.nix` for thermald plus zram.

The hardware file is a deliberate placeholder with fake by-label devices
(`NIXOS-LAPTOP-ROOT` and friends) so the flake still evaluates and
`nix flake check` passes. It must be regenerated on the laptop itself before
ever being switched to. The desktop UUIDs must not be copied.

First attempt failed to evaluate with `undefined variable 'modulesPath'`,
fixed by adding it to the submodule arguments, same as the blob hardware file
does.

## verification

- `nix flake check --no-build` passes for both hosts
- `nixosConfigurations.blob` builds fully
- `nixosConfigurations.laptop` evaluates but cannot build a usable system until
  the hardware file is real, by design
- The laptop host exists so `blob` is untouched by laptop-specific choices

## commits

NixOS repo, pushed to `EGRrqq/nixos`:

- `ac493cf` Add webdav, libvirt and a laptop host
- `8b9eab0` Add alsa-utils for raw midi events
- `f890afc` Add disk tools
- `916e01c` Fix the gnome-disks package name
- `99d48af` Add gcc16 for gopls
- `152a4b7` Add a data drive with monthly snapshots

niri repo, pushed to `EGRrqq/niri`:

- `b776f06` Important hotkey titles
- `47b7e4d` Slow down key repeat and add a layout switch

## mistakes made and fixed

- Wrote `gnome-disks` as a nixpkgs attribute. The attribute is
  `gnome-disk-utility`, and the binary inside it is `gnome-disks`. The user hit
  this as an eval error and caught it. Fixed in `916e01c` and verified the
  binary exists in the built system
- A stray file called `printf 'ok\n'` got created by a shell redirection typo
  and was staged by `git add -A`. Removed
- Used `systemd.timers.x.calendar` and `persistent`, which no longer exist in
  current nixpkgs. Read `nixos/lib/systemd-unit-options.nix`, switched to
  `timerConfig = { OnCalendar = "..."; Persistent = true; }`
- Nearly shipped a `/mnt/data` mount that would have dropped the machine into
  emergency mode on the next boot because the disk was not formatted yet. Added
  `nofail`
- Alsa-utils and gnome-disks were added to `app-base.nix`, which also carried
  the user's uncommitted `gcc16`. Committed only my hunks by writing the
  intended file content to a blob and pointing the index entry at it, so the
  user's change stayed untouched in the working tree until they asked for it to
  be committed separately

## disk

`sdb` identified as SPCC Solid State, 55.9 GB, SATA, non-rotational, no
partition table, no filesystem, not mounted. No data on it that NixOS knows
about.

`smartctl` could not read it before the rebuild, permission denied, because the
`disk` group is not active in the current session. This is expected and
resolves after `nixos-rebuild switch` and a new login.

Added `gnome-disk-utility` and `smartmontools` to `app-base.nix`. `cfdisk` was
already present.

User decisions taken:

- The Windows VM disk goes on `sda2`, not on `sdb`, so it can grow without
  being reinstalled. 100 GB virtual size
- `sdb` becomes btrfs at `/mnt/data` with monthly snapshots, for Blender and
  motion graphics projects
- Explained and accepted that snapshots are not a backup, `sdc` is for copies

## sdb, the correction

An earlier check with `lsblk` showed no partitions and the agent reported the
disk as having no partition table. That was wrong in the literal sense.
`blkid -p` and `wipefs -n` show an empty GPT header on it, with the partition
entry array at LBA 2 all zeros. No partitions were ever created and no
filesystem of any kind exists. SMART would not pass through on this controller
without root, so the drive history could not be confirmed, only the absence of
anything stored. The user approved formatting after being told this.

Formatted `sdb` with `mkfs.btrfs -f -L data`, UUID
`de1505d1-9082-4a96-b373-19528ff443ba`. btrfs picked single data with DUP
metadata, which is right for a 56 GB drive.

Mounting and creating the subvolume need root, the agent only has the `disk`
group through `sg disk` after the switch, which is enough to write the
filesystem but not enough to mount it.

## the snapshot bug, found before it bit

The first version of `hw-storage.nix` did
`btrfs subvolume snapshot -r /mnt/data /mnt/data/.snapshots/<date>` with
`.snapshots` created by `mkdir -p`, so a plain directory. A plain directory
inside the snapshotted subvolume means every new snapshot contains all the
older snapshots, and on a 56 GB drive that fills up by itself within a few
months.

Fixed by making `.snapshots` a btrfs subvolume, since nested subvolumes are not
copied into a snapshot of their parent. The service now refuses to run if it is
missing, and prints the command to create it, rather than silently mkdir-ing it
and bringing the growth problem back.

Ownership of the mount point goes through a tmpfiles rule so the user does not
need sudo to write there.

The pruning logic was checked on realistic `btrfs subvolume list` output: with
14 monthly snapshots it selects the two oldest for deletion and keeps 12. An
earlier version of that test was wrong because `seq -w` does not pad to two
digits when the largest number is single digit, the padding was faked with
`printf %02d`.

## what is left on the disk

One sudo command for the user, then it is done:
`systemctl start mnt-data.mount`, `btrfs subvolume create
/mnt/data/.snapshots`, `chown egr:egr` on both, and `systemctl start
storage-snapshot.service`.

The user ran it. Mount and subvolume creation succeeded, `chown` failed with
`invalid group: egr:egr`, which broke the `&&` chain so the snapshot service
never ran. There is no `egr` group, the primary group is `users` with gid 100.
The tmpfiles rule in `hw-storage.nix` had the same mistake and would have
failed on every boot, fixed in `71280b8` to `egr users`.

Corrected command for the user:
```
sudo chown egr:users /mnt/data /mnt/data/.snapshots && sudo systemctl start storage-snapshot.service
```

## the agent cannot inspect btrfs subvolumes

`btrfs subvolume list`, `subvolume show` and `get-default` return
`Could not search B-tree: Operation not permitted` in the agent shell, while
`btrfs filesystem show` and `mkfs` work. `filesystem show` uses a different
ioctl, so this is ioctl filtering in the sandbox rather than anything wrong
with the disk. Noted in `context.md` so later sessions ask the user to run
those commands instead of guessing.

Confirmed the snapshot script runs with `set -e` but no `pipefail`, so an empty
grep inside the pruning pipeline will not abort it.

## midi

Researched the openDAW repo, 59 open issues, nothing matching stuck notes
specifically. So no known app bug to point at yet.

`aseqdump -l` shows no MIDI input at all, only the internal `Midi Through
Port-0`. The M-Vave controllers are not connected. Bluetooth and USB both need
to be compared, which needs the hardware plugged in.

Added `alsa-utils` to `hw-audio.nix` so `aseqdump`, `amidi` and `aconnect` are
available for the capture.
