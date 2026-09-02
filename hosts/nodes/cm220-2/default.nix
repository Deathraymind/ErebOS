{lib, ...}: {
  imports = [
    ./hardware.nix
    ./sd.nix
    ../../../modules/ishikori/incus-host.nix
  ];
  networking.hostId = "63a58548"; # must be unique per node (ZFS)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiInstallAsRemovable = false;
}
