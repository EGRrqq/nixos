{ self, inputs, ... }:
{
  flake.nixosModules.gvfs = { pkgs, lib, ... }: {
    # GVFS daemon with the WebDAV backend (gvfsd-dav). Mount a cloud
    # provider from the file manager or from yazi: M m, then a davs:// URI,
    # for example davs://webdav.yandex.ru/ or davs://cloud.mail.ru/
    services.gvfs.enable = true;

    # gio lives in the bin output of glib, so it is not in PATH on its own
    environment.systemPackages = [
      (lib.getBin pkgs.glib)
      pkgs.gvfs
    ];
  };
}