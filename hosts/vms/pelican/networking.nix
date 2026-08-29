{
  pkgs,
  lib,
  ...
}: {
  virtualisation.incus.agent.enable = true;

  # Static networking (scripted backend)
  networking = {
    hostName = "pelican";
    useDHCP = false;

    interfaces.enp5s0.ipv4.addresses = [
      {
        address = "192.168.1.50";
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];

    firewall.allowedTCPPorts = [8080 2022 80 443];
  };

  time.timeZone = "Asia/Tokyo";

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
