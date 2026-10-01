{ self, inputs, ... }:
{
  flake.nixosModules.basePackages = { lib, pkgs, ... }: {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    environment.systemPackages = with pkgs; [
      xwayland-satellite

      # Shell
      nushell
      carapace
      vivid
      starship

      # Terminals & editors
      wezterm
      neovim
      brave

      # CLI utilities
      git
      gh
      unzip
      wget
      fzf
      ripgrep
      tree-sitter
      fd
      sshs
      wl-clipboard

      # Disks
      gnome-disk-utility
      smartmontools

      python314
      python314Packages.pip
      python314Packages.jupyterlab

      gcc16
      llvmPackages_23.clangNoLibcxx # the compiler (uses libstdc++ to match GCC)
      llvmPackages_23.clang-tools
      cpplint

      lua
      luau
      go
      rustc
      cargo
      php

      nodejs_26
      biome
      corepack
      live-server
      bun
      deno

      noctalia-shell

      # Media keys
      playerctl
      brightnessctl
    ];
  };
}
