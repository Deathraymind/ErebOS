{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = ["${modulesPath}/virtualisation/lxc-container.nix"]; # sets boot.isContainer, no bootloader/fstab

  networking.hostName = "ct15";
  networking.useDHCP = false;
  networking.interfaces."eth0@if8".ipv4.addresses = [
    {
      address = "192.168.1.15";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = ["192.168.1.1"];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.deathraymind = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1p2OamHpIwYUh0mS3yj/CDmT01n4leoYCd/tuqMJHt deathraymind@gmail.com"
    ];
    hashedPassword = "$6$X6ADCAYJr36.atJY$aOzF6Drf0YEq2ac3QnFFU3bhJZNuY/hX9Fux6dcJCeiQTNBK1F3oFKqqlhpUoKVJA34gfIWs0VkcO1051jn5d0";
  };
  services.coredns = {
    enable = true;
    config = ''
      home.arpa {
        hosts {
          192.168.1.53  dns.home.arpa
          192.168.1.10  nas.home.arpa
          192.168.1.30  grafana.home.arpa
          ttl 60
          fallthrough
        }
      }

      # --- Incus auto-records: flip this on later, once instances live on an
      # --- Incus-owned network and you've set core.dns_address + the zone peer
      # home.incus {
      #   secondary {
      #     transfer from 192.168.1.100:1053
      #   }
      # }

      . {
        forward . 1.1.1.1 9.9.9.9
        cache 30
        log
        errors
      }
    '';
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05";
}
