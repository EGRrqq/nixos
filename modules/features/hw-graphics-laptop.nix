{ self, inputs, ... }:
{
  flake.nixosModules.laptopGraphics =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Acer Aspire V3-571, Intel HD Graphics 4000 plus an NVIDIA card that
      # nothing here needs. The laptop runs on the Intel chip through
      # modesetting, it is cool, quiet and does not depend on the nvidia
      # driver at all. Offload to the discrete card can be added later, it
      # needs the bus ids from lspci -nnk
      hardware.graphics.enable = true;

      services.xserver.videoDrivers = [ "modesetting" ];

      # Wayland / XWayland
      services.xserver.enable = true;

      # Keymap in X11, has to match niri
      services.xserver.xkb = {
        layout = "us,ru";
        variant = "";
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
      };
    };
}