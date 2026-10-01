# Context

## Machine, desktop

Verified with `lsblk`, `lscpu`, `lspci`, `df`.

- CPU: Ryzen 1400, 4 cores 8 threads
- RAM: 32 GB, single channel. This hurts MoE inference and MoE offload
- GPU: GeForce GTX 1050 Ti, 4 GB VRAM, PCIe passthrough to a Windows guest
- Disks:
  - `sda` 465.8 GB, the system disk
    - `sda1` 1 GB vfat at `/boot`
    - `sda2` 456 GB ext4, holds `/` and `/nix/store`, 386 GB free at last check
    - `sda3` 8.8 GB swap
  - `sdb` 55.9 GB SPCC Solid State, SATA, no partition table, no filesystem
    (model read from `/sys/block/sdb/device/model`, non-rotational)
  - `sdc` 1.8 TB exFAT, unmounted, free. Meant to be the backup target
- Keyboard: niri, layout `us,ru`, Super+Space switches
- Printer: HP DeskJet 1510, works on NixOS through HPLIP for printing and
  scanning, so the Windows guest is not needed for scanning

## Machine, laptop

- Acer Aspire V3-5716
- CPU: i5-3210M
- RAM: 8 GB
- Disk: WD5000LPLX, spinning
- GPU: Intel HD 4000 plus NVIDIA N13P-GL
- Decision: Intel only graphics with modesetting. The NVIDIA card buys nothing
  there and only adds a driver dependency. Offload later, if ever, needs the
  real bus ids from `lspci -nnk`
- Decision: thermald for the CPU, zram for swap
- Its `hardware-configuration.nix` is still a placeholder and must be
  regenerated on the laptop itself

## Software

- NixOS unstable, channel 26.11, `system.stateVersion = "26.05"`
- systemd-boot, UEFI
- Display: niri with noctalia-shell
- Audio: PipeWire with WirePlumber, JACK enabled, PulseAudio off
- Bluetooth: BlueZ, experimental features on
- Containers: podman
- Package management by Nix, everything declarative
- Shell: nushell with starship, carapace, vivid

## Repos

- `~/.config/nixos` -> github.com/EGRrqq/nixos. Main work
- `~/.config/niri` -> github.com/EGRrqq/niri
- `~/.config/noctalia`
- `~/.config/yazi`, `~/.config/git`, `~/.config/bash`, `~/.config/nushell`,
  `~/.config/carapace`
- All managed by home-manager or by the flake's own modules

## Flake outputs

- `nixosConfigurations.blob`, hostname `nixos`, the desktop
- `nixosConfigurations.laptop`, hostname `laptop`
- `flake.nixosModules.*` are the dendritic building blocks, one concern per
  file, under `modules/features/`
- Naming convention: `app-*` applications, `hw-*` hardware, `srv-*` services,
  `sys-*` system basics, `desktop-*` desktop

## Access and environment facts

- `sudo` needs a password, the agent cannot run `nixos-rebuild switch`. Builds
  and evals work fine, activation has to be done by the user
- SSH has no usable key. Push over HTTPS with the `gh` credential helper:
  `git push https://github.com/OWNER/REPO.git HEAD:main`
- Disk access needs the `disk` group, which only lands after a rebuild and
  re-login. Before that, `/dev/sdb` reads fail with permission denied. As a
  stopgap `sg disk -c '...'` works, it looks the group up in `/etc/group`
  without needing a new login
- `btrfs subvolume list`, `subvolume show` and `get-default` fail with
  `Could not search B-tree: Operation not permitted` for a normal user on this
  box, root is required. `filesystem show`, `filesystem df`, `filesystem usage`
  and `device show` work fine because they use other ioctls. Same class of
  problem is tracked upstream at kdave/btrfs-progs#757. This is not the agent
  sandbox, it reproduces in the user's own terminal. Do not build anything that
  needs a btrfs tree search as a user. Listing subvolume directories by name is
  the workaround that needs no privilege
- There is no group named `egr`. The primary group is `users`, gid 100.
  `/etc/passwd` shows `egr` in the group name field but nothing resolves it, so
  always use `user:users` in chown and tmpfiles rules
- Untracked files are invisible to `git+file`, so new modules have to be
  `git add`ed before `nix flake check` will see them. Evaluate with
  `path:/home/egr/.config/nixos` while experimenting
- `seq -w` does not zero-pad when the largest number is single digit, fake it
  with `printf %02d` when testing date logic

## Decisions and their reasons

- No `wrapper-modules`. niri and noctalia are configured on their own now, a
  wrapper module would no longer feed them anything
- `app-brave`, `app-vscode`, `app-yazi` stay as modules even after their
  configs moved out of home-manager. The package and extra packages are still
  needed and the plugin wiring still lives there
- `lib.getBin glib` for `gio`. `pkgs.glib` has no `bin` directory, the `bin`
  output does
- `pkgs.gvfs` already contains `gvfsd-dav`. There is no `gvfs-backends`
  package in current nixpkgs
- WebDAV endpoints:
  - Mail.ru `https://webdav.cloud.mail.ru`
  - Yandex `https://webdav.yandex.ru`, GVFS mounts it as `davs://...`
- Credentials stay out of Nix. The user runs `rclone config` and keeps the
  file out of the repo
- Disk switching in yazi is by keymap, not a plugin. `g m` to `/mnt` as the hub
  that shows every mounted disk at once, `g r` to `/mnt/data`, `g v` to
  `/run/user/1000/gvfs` for WebDAV. `/mnt` only holds `data` right now, the
  parent panel is not a disk list
- yazi 26.9.1 already ships `g <Space>` as `cd --interactive` with path
  completion, and the user has the `bookmarks` plugin on `m` and `'`. Both stay,
  the new `g` keys sit in the subkeys that are free: `g m`, `g r`, `g v`, while
  `g h/c/d/t/f` are yazi defaults and `g i/o/u//` were already taken
- Moving 600 GB between Yandex and Mail.ru uses `rclone copy` between remotes.
  Data still passes through the local machine, there is no cross-provider
  server-side copy, but this avoids two FUSE mounts and gets retries, checks
  and chunking
- Windows runs as a qcow2 guest under libvirt on `sda2`, not dual boot
- VM disk 100 GB, growable, qcow2 is sparse so it only uses what is put in it
- `sdb` becomes btrfs at `/mnt/data` with monthly snapshots, chosen for
  projects like Blender and motion graphics
- btrfs snapshots are not a backup. They cover deleted files and corruption,
  not a dead drive. `sdc` is the copy target
- `/mnt/data` is mounted `nofail`, otherwise an unformatted or missing drive
  would stop the boot
- In current nixpkgs `systemd.timers.<name>` has no `calendar` or `persistent`
  options any more. Use `timerConfig = { OnCalendar = "..."; Persistent = true; }`
- NixOS 26.x `systemd.services.*.script` runs through bash, so normal shell
  quoting and `$(...)` work, and `%` needs no escaping unless systemd
  specifiers are used
- Hotkey overlay titles in niri use `hotkey-overlay-title="..."`. An equals
  sign is required, the file does not validate without it
- Niri has no option for overlay font size or window size, the overlay is
  hardcoded to `sans 14px`. The user accepted that and wanted titles only
- niri key repeat went to 250 ms delay and 32 repeats per second, the old 200
  and 35 produced doubled symbols
- `gcc16` is in `app-base.nix` because gopls in neovim needs a newer gcc than
  the default one. That was a user change, committed separately on request

## Style

- Dendritic modules, one concern per file
- Comments explain why, not what. The code already says what
- READMEs only when something is genuinely not obvious. No AI-ish filler, no
  em dashes, no long dashes, no restating the config in prose
- The user writes in English and Russian, both are fine

## Unresolved questions

- Where does the thin light outline around focused windows come from. niri has
  `focus-ring width 1.5`, `gaps 5`, `border off`, `geometry-corner-radius 4`
  and `clip-to-geometry true`. Could be the ring itself, anti-aliasing of the
  clip, or a noctalia decoration. Not answered yet
- Which Windows edition and ISO. Needs a licensed image, the agent cannot
  obtain one
- HP DeskJet 1510 USB VID/PID, needed for passthrough. Requires the printer to
  be plugged in and `lsusb` run
