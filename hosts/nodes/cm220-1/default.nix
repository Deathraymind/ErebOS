{...}: {
  imports = [
    ./hardware.nix
    ../../../modules/ishikori/incus-host.nix
  ];
  networking.hostName = "cm220-1";
  networking.hostId = "63a58548"; # must be unique per node (ZFS)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiInstallAsRemovable = false;

  #fileSystems."/srv/share" = {
  # Replace with the actual IP of the other server and the path it exports
  # device = "10.0.0.1:/srv/share";
  # fsType = "nfs";

  # These options are crucial: they mount the share "on demand"
  # so your VM server doesn't freeze during boot if the remote server is offline.
  # options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  # };
}
