{lib, ...}: {
  imports = [
    ./hardware.nix
    ./incus-host.nix
    ./sd.nix
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

  networking.useDHCP = false;
  networking.nameservers = lib.mkDefault ["1.1.1.1" "8.8.8.8"];

  networking.interfaces.br0.ipv4.addresses = [
    {
      address = "192.168.1.97";
      prefixLength = 24;
    }
  ];

  virtualisation.libvirtd.allowedBridges = ["br0" "virbr0"];

  # 10G direct node-to-node link (systemd-networkd)
  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;
  #systemd.network.networks."10-tengig" = {
  #matchConfig.PermanentMACAddress = cfg.tengigMac;
  #address = ["${cfg.tengigAddress}/24"];
  #linkConfig.RequiredForOnline = "no";
  #};
}
