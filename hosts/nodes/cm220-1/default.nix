{...}: {
  imports = [
    ../../../modules/ishikori/qemu-node.nix
    ./hardware.nix
  ];
  programs.vm-restic-backup = {
    enable = true;
    vms = ["caddy" "pelican" "pelican-wings" "vaultwarden"];
    repository = "s3:https://ee25c8a9bd470793ee087dabb15f70fd.r2.cloudflarestorage.com/hypervisor-backups/restic";
  };
  networking.hostName = "cm220-1";
  networking.hostId = "63a58548"; # must be unique per node (ZFS)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiInstallAsRemovable = false;

  homelab.node = {
    lanAddress = "192.168.1.98";
    bridgeInterface = "enp1s0f0";

    tengigAddress = "10.0.0.3";
    tengigMac = "80:3f:5d:d3:ae:ed";
    peerIps = ["192.168.1.100" "192.168.1.99"];
  };
  #fileSystems."/srv/share" = {
  # Replace with the actual IP of the other server and the path it exports
  # device = "10.0.0.1:/srv/share";
  # fsType = "nfs";

  # These options are crucial: they mount the share "on demand"
  # so your VM server doesn't freeze during boot if the remote server is offline.
  # options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  # };
  programs.qemu-live-export.outputDir = "/srv/share/cold-export";
}
