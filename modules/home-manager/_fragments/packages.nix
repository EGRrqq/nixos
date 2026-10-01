{ lib, pkgs, ... }:
let
  # symlinkJoin keeps the upstream share/ (icons, desktop files) that
  # writeShellScriptBin drops, makeWrapper only touches the binary
  scaledQt = {
    name,
    bin,
    pkg,
    scale,
  }: pkgs.symlinkJoin {
    name = "${name}-scaled";
    paths = [ pkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${bin} \
        --set-default QT_SCALE_FACTOR ${scale} \
        --set-default QT_AUTO_SCREEN_SCALE_FACTOR 0
    ''
    + lib.optionalString (bin != name) ''
      ln -s ${bin} $out/bin/${name}
    '';
  };
in
{
  home.packages = with pkgs; [
    (scaledQt {
      name = "qbittorrent";
      bin = "qbittorrent";
      pkg = pkgs.qbittorrent;
      scale = "1.5";
    })

    (scaledQt {
      name = "vial";
      bin = "Vial";
      pkg = pkgs.vial;
      scale = "1.3";
    })

    # Editors & AI tools
    helix
    vscode
    opencode
    aider-chat-full
    pi-coding-agent

    # GUI apps
    telegram-desktop
    obsidian
    mpv
    zathura
    bitwarden-desktop
    localsend

    # Cloud storage
    rclone # WebDAV and other remotes, rclone copy between them
    (lib.getBin glib) # gio, used by the yazi gvfs plugin
  ];

  xdg.desktopEntries = {
    vial = {
      name = "Vial";
      genericName = "Keyboard firmware configurator";
      comment = "Configure QMK/VIAL keyboard firmware";
      exec = "vial";
      icon = "${pkgs.vial}/share/icons/hicolor/256x256/apps/Vial.png";
      categories = [ "Utility" ];
      terminal = false;
    };

    qbittorrent = {
      name = "qBittorrent";
      genericName = "BitTorrent client";
      comment = "Download and share files over BitTorrent";
      exec = "qbittorrent %U";
      icon = "${pkgs.qbittorrent}/share/icons/hicolor/192x192/apps/qbittorrent.png";
      categories = [
        "Network"
        "FileTransfer"
      ];
      mimeType = [
        "application/x-bittorrent"
        "x-scheme-handler/magnet"
      ];
      settings = {
        StartupWMClass = "qbittorrent";
        SingleMainWindow = "true";
      };
      terminal = false;
    };

    lmstudio = {
      name = "LM Studio";
      exec = "${pkgs.writeShellScriptBin "lmstudio" ''
        exec ${pkgs.lmstudio}/bin/lm-studio --force-device-scale-factor=1.8 "$@"
      ''}/bin/lmstudio";
      icon = "lm-studio";
      categories = [ "Development" ];
      terminal = false;
    };
  };
}