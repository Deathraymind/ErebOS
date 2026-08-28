{lib, ...}: {
  imports = [
    ./hardware.nix
    ./incus-host.nix
    ./sd.nix
  ];
  networking.hostName = "cm220-2";
  networking.hostId = "63a58548"; # must be unique per node (ZFS)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiInstallAsRemovable = false;

  networking.useDHCP = false;

  networking.interfaces.br0.ipv4.addresses = [
    {
      address = "192.168.1.97";
      prefixLength = 24;
    }
  ];
  ############################################################
  ## SSH / Nix
  ############################################################
  services.openssh.enable = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "deathraymind"];

  ############################################################
  ## Users
  ############################################################
  users.users.deathraymind = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = ["wheel" "incus-admin"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1p2OamHpIwYUh0mS3yj/CDmT01n4leoYCd/tuqMJHt deathraymind@gmail.com"
    ];
    hashedPassword = "$6$X6ADCAYJr36.atJY$aOzF6Drf0YEq2ac3QnFFU3bhJZNuY/hX9Fux6dcJCeiQTNBK1F3oFKqqlhpUoKVJA34gfIWs0VkcO1051jn5d0";
  };

  # 10G direct node-to-node link (systemd-networkd)
  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;
  #systemd.network.networks."10-tengig" = {
  #matchConfig.PermanentMACAddress = cfg.tengigMac;
  #address = ["${cfg.tengigAddress}/24"];
  #linkConfig.RequiredForOnline = "no";
  #};
}
