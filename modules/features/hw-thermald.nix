{ self, inputs, ... }:
{
  flake.nixosModules.thermald = { pkgs, lib, ... }: {
    # Throttling and fan control on the Intel CPU
    services.thermald.enable = true;

    # Swap in RAM, 8 GB of memory with a spinning disk is not much
    zramSwap = {
      enable = true;
      memoryPercent = 50;
      algorithm = "zstd";
    };
  };
}