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

Both rebuilds are applied. Second one, generation `clc2dg0v...`, was verified:

- the three yazi keys `g m`, `g r`, `g v` are in the live
  `YAZI_CONFIG_HOME/keymap.toml` inside the new generation
- `storage-snapshot.service` now runs `names=$(ls -1 /mnt/data/.snapshots)`
  instead of walking the btrfs tree, so the permission bug is gone
- `/etc/tmpfiles.d/00-nixos.conf` has `d /mnt/data 0755 egr users - -`, the
  group `egr` never existed so the old rule was silently wrong
- `mnt-data.mount` and `storage-snapshot.timer` both active

Still open: the `disk`, `libvirtd`, `kvm` and `input` groups do not apply to
the current session yet, so `/dev/sdb` still reads as permission denied until
the user logs out and back in.

## Next

1. Finish the Mail.ru remote. `yandex` is done and verified. `mailru` still
   fails with `oauth2: "invalid username or password"`. Root cause is the app
   password scope, not the config. See the `rclone` section in `history.md`
   for the length arithmetic and the forum thread
2. Verify with `rclone about mailru:`, `rclone about yandex:` and
   `rclone lsd mailru:`
3. Migrate Mail.ru to Yandex, about 600 GB, one way, because the Mail.ru
   subscription expires soon. `rclone copy mailru: yandex:` with native hashes
   on both sides, so a re-run skips what already matched. Measure the speed on
   a small directory first to get a realistic ETA before starting the bulk
4. Check WebDAV mounts from yazi, `davs://webdav.yandex.ru/` and
   `davs://cloud.mail.ru/`. `g v` jumps straight to the GVFS hub. Independent of
   the rclone backend, gvfs speaks WebDAV
5. MIDI. Plug the M-Vave in, compare USB-C against Bluetooth, and capture
   events with `aseqdump -l` first to find the port, then
   `aseqdump -p <port>` while playing in openDAW. If NoteOff shows up in the
   capture the problem is in the app or the browser Web MIDI layer. If it never
   arrives the loss is in the transport

## Blocked, needs hardware or a decision

6. Windows VM. Blocked on a licensed ISO from the user and on the HP DeskJet
   1510 VID/PID. Once the ISO is on disk, `virt-install` can do the rest:
   100 GB qcow2 on `sda2`, virtio, SPICE, UEFI. Needs the printer plugged in
   and `lsusb` output for passthrough
7. Laptop. Blocked on the user generating the real hardware configuration on
   the laptop itself, and ideally `lspci -nnk` for GPU bus ids
8. Focus ring. Unanswered. Need to know whether the thin outline is seen in a
   normal window or only in the noctalia overview, and whether it is on the
   focused window or on every window
9. `sdc` as backup target. 1.8 TB exFAT, unmounted. Needs a decision on whether
   to mount it by UUID in fstab or leave it manual

## Queued, not started

10. README updates. Only for things a reader cannot infer. Storage, the VM and
    the laptop host are candidates, hotkey titles are not

11. Local AI models and tooling. Requirements are captured verbatim in
    `ai-models.md`. Plan mode has to be turned on before this starts, the user
    asked for that explicitly. Kept last on purpose. Hardware budget:
    GTX 1050 Ti 4 GB VRAM, 32 GB single-channel RAM, Ryzen 1400

## Notes

- Every new module file must be `git add`ed before `nix flake check` sees it,
  because the flake reads the git tree
- Push with HTTPS, SSH has no key on this machine:
  `git push https://github.com/EGRrqq/nixos.git HEAD:main`
