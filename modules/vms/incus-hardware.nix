# Common hardware module for all Incus VMs.
# Import this from every Incus VM host instead of a per-VM generated
# hardware-configuration.nix. Works across VMs because it references
# filesystems by LABEL (nixos / ESP), which are identical on every VM,
# rather than by UUID (which is unique per disk).
{
  modulesPath,
  lib,
  ...
}: {
  imports = [
    # Provides: qemu-guest profile, UEFI systemd-boot, virtio modules,
    # and the incus guest agent. Do NOT add grub or systemd-boot yourself.
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
