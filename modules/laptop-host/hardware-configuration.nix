# Nothing below is real. Generate the file on the laptop itself, from a live
# session, and replace every placeholder:
#
#   sudo nixos-generate-config --show-hardware-config > /tmp/hw.nix
#
# Then wrap it the way blob-host/hardware-configuration.nix does, keeping the
# export name laptopHardware. Do not copy the UUIDs from the blob host, they
# belong to the desktop.
#
# The placeholder devices are on purpose not real, this host is here so the
# config is ready to be filled in, and it must not be switched to before that
# happens.

{ self, inputs, ... }:
{
  flake.nixosModules.laptopHardware =
    {
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "sd_mod"
      ];
      boot.kernelModules = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXOS-LAPTOP-ROOT";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/NIXOS-LAPTOP-BOOT";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        {
          device = "/dev/disk/by-label/NIXOS-LAPTOP-SWAP";
        }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}