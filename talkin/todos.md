# Todos

Ordered by what blocks what.

## Done

- [x] Explain and remove `wrapper-modules`
- [x] Important hotkey titles in niri, `b776f06`
- [x] Key repeat and layout switch in niri, `47b7e4d`
- [x] GVFS module, rclone and `gio` for yazi
- [x] libvirt, qemu, virt-manager, SPICE
- [x] laptop host skeleton with Intel-only graphics
- [x] alsa-utils for MIDI diagnostics
- [x] gnome-disk-utility and smartmontools
- [x] `gcc16` committed separately for gopls, `99d48af`
- [x] `hw-storage.nix` with btrfs `/mnt/data` and monthly snapshots, `152a4b7`
- [x] Quick disk switching in yazi: `g m` `/mnt`, `g r` `/mnt/data`,
      `g v` GVFS
- [x] All of the above pushed to GitHub

## Rebuild

One rebuild has been applied. The user ran it and it applied cleanly. Verified
afterwards:

- `/run/current-system` is generation `id4m03pr...`, matching what the agent
  built before the switch
- `gnome-disks`, `smartctl`, `aseqdump`, `rclone`, `gio`, `virsh`,
  `virt-manager` all resolve now
- `/etc/fstab` has `/dev/disk/by-label/data /mnt/data btrfs
  compress=zstd,noatime,nofail 0 0`, and `mnt-data.mount` is generated
- `storage-snapshot.timer` is scheduled, next run 2026-11-01 04:00
- `libvirtd.socket` is active, `virsh --connect qemu:///system` answers with an
  empty domain list, so libvirt is usable

A second rebuild is pending, nothing depends on it yet:
- `a50dca1` snapshots as a subvolume, tmpfiles ownership
- `71280b8` tmpfiles owner `egr:users`, the group `egr` does not exist
- `47e8cf0` pruning via `ls -1` instead of `btrfs subvolume list`
- the new yazi `g m` / `g r` / `g v` keys

The active generation still carries the old unit script and the old tmpfiles
rule. Ownership on disk was fixed by hand, so nothing is broken until the
rebuild lands.

Still open: the `disk`, `libvirtd`, `kvm` and `input` groups do not apply to
the current session yet, so `/dev/sdb` still reads as permission denied until
the user logs out and back in.

## Next

1. Set up rclone remotes. The user runs `rclone config` and enters their own
   app passwords. Never into Nix. Remotes: `yandex` at
   `https://webdav.yandex.ru`, `mailru` at `https://webdav.cloud.mail.ru`
2. Check WebDAV mounts from yazi, `davs://webdav.yandex.ru/` and
   `davs://cloud.mail.ru/`. `g v` jumps straight to the GVFS hub
3. MIDI. Plug the M-Vave in, compare USB-C against Bluetooth, and capture
   events with `aseqdump -l` first to find the port, then
   `aseqdump -p <port>` while playing in openDAW. If NoteOff shows up in the
   capture the problem is in the app or the browser Web MIDI layer. If it never
   arrives the loss is in the transport

## Blocked, needs hardware or a decision

4. Windows VM. Blocked on a licensed ISO from the user and on the HP DeskJet
   1510 VID/PID. Once the ISO is on disk, `virt-install` can do the rest:
   100 GB qcow2 on `sda2`, virtio, SPICE, UEFI. Needs the printer plugged in
   and `lsusb` output for passthrough
5. Laptop. Blocked on the user generating the real hardware configuration on
   the laptop itself, and ideally `lspci -nnk` for GPU bus ids
6. Focus ring. Unanswered. Need to know whether the thin outline is seen in a
   normal window or only in the noctalia overview, and whether it is on the
   focused window or on every window
7. `sdc` as backup target. 1.8 TB exFAT, unmounted. Needs a decision on whether
   to mount it by UUID in fstab or leave it manual

## Queued, not started

8. README updates. Only for things a reader cannot infer. Storage, the VM and
   the laptop host are candidates, hotkey titles are not

9. Local AI models and tooling. Requirements are captured verbatim in
   `ai-models.md`. Plan mode has to be turned on before this starts, the user
   asked for that explicitly. Kept last on purpose. Hardware budget:
   GTX 1050 Ti 4 GB VRAM, 32 GB single-channel RAM, Ryzen 1400

## Notes

- Every new module file must be `git add`ed before `nix flake check` sees it,
  because the flake reads the git tree
- Push with HTTPS, SSH has no key on this machine:
  `git push https://github.com/EGRrqq/nixos.git HEAD:main`
