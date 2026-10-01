{ self, inputs, ... }:
{
  flake.nixosModules.libvirt = { pkgs, ... }: {
    # KVM and libvirt, for running a Windows VM. virt-manager is the GUI, a
    # USB device with a scanner can be passed through to a guest from there,
    # by vendor and product id
    virtualisation.libvirtd.enable = true;

    # virt-manager picks firmware and machine type on its own, these are here
    # so UEFI, a software TPM and the matching qemu are available
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu_kvm
      qemu-utils
      OVMFFull
      swtpm
    ];

    # USB redirection over SPICE, a guest can take a USB device without
    # unbinding it on the host
    services.spice-vdagentd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    users.users.egr = {
      extraGroups = [
        "libvirtd"
        "kvm"
        "input"
        "disk"
      ];
    };
  };
}