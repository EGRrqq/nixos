# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ self, inputs, ... }:
{
  flake.nixosModules.blobConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.blobHardware

        # Base system features
        self.nixosModules.nixSettings
        self.nixosModules.locale
        self.nixosModules.network
        self.nixosModules.security
        self.nixosModules.nixGc

        # Hardware features
        self.nixosModules.graphics
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.printing
        self.nixosModules.tablet
        self.nixosModules.fonts
        self.nixosModules.storage

        # Desktop
        self.nixosModules.displayManager
        self.nixosModules.niri
        self.nixosModules.basePackages
        self.nixosModules.gnomeKeyring
        self.nixosModules.brave
        self.nixosModules.yazi

        # Users
        self.nixosModules.userEgr

        # Network features
        self.nixosModules.zapret

        self.nixosModules.vscode
        self.nixosModules.udev
        self.nixosModules.containers
        self.nixosModules.gvfs
        self.nixosModules.libvirt

        inputs.home-manager.nixosModules.home-manager
      ];

      myModules.containers.backend = "podman";

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        users.egr = self.homeModules.egr;
      };

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "nixos"; # Define your hostname.

      # Display manager configuration (via reusable module)
      myModules.displayManager = {
        enable = true;
        defaultSession = "niri";
        autoLogin = {
          enable = true;
          user = "egr";
        };
      };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "26.05"; # Did you read the comment?
    };
}
