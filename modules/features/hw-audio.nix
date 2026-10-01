{ self, inputs, ... }:
{
  flake.nixosModules.audio =
    { pkgs, lib, ... }:
    {
      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;

      # aseqdump and friends, for looking at raw midi events when something
      # gets stuck or disappears
      environment.systemPackages = with pkgs; [
        alsa-utils
      ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # Enable JACK for routing MIDI and low-latency audio
        jack.enable = true;
        # Ensure WirePlumber is active to manage the MIDI nodes
        wireplumber.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };
    };
}