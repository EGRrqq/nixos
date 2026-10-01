{ self, inputs, ... }:
{
  flake.nixosModules.laptopConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        # Result of the hardware scan, generated on the laptop itself
        self.nixosModules.laptopHardware

        # Base system features
        self.nixosModules.nixSettings
        self.nixosModules.locale
        self.nixosModules.network
        self.nixosModules.security
        self.nixosModules.nixGc

        # Hardware features, graphics is the laptop one, Intel only
        self.nixosModules.laptopGraphics
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.printing
        self.nixosModules.fonts
        self.nixosModules.thermald

        # Desktop
        self.nixosModules.displayManager
        self.nixosModules.niri
        self.nixosModules.basePackages
        self.nixosModules.gnomeKeyring
        self.nixosModules.yazi

        # Users
        self.nixosModules.userEgr

        self.nixosModules.containers
        self.nixosModules.gvfs

        inputs.home-manager.nixosModules.home-manager
      ];

      myModules.containers.backend = "podman";

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        users.egr = self.homeModules.egr;
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "laptop";

      myModules.displayManager = {
        enable = true;
        defaultSession = "niri";
        autoLogin = {
          enable = true;
          user = "egr";
        };
      };

      system.stateVersion = "26.05";
    };
}