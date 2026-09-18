{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [];
  virtualisation.diskSize = lib.mkForce 30480;
  # --- USER CONFIGURATION ---
  users.users.deathraymind = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = ["wheel"];
    hashedPassword = "$6$X6ADCAYJr36.atJY$aOzF6Drf0YEq2ac3QnFFU3bhJZNuY/hX9Fux6dcJCeiQTNBK1F3oFKqqlhpUoKVJA34gfIWs0VkcO1051jn5d0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1p2OamHpIwYUh0mS3yj/CDmT01n4leoYCd/tuqMJHt deathraymind@gmail.com"
    ];
  };
  # --- CONTAINERS CONFIGURATION ---
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      vaultwarden = {
        image = "vaultwarden/server:latest";
        ports = ["192.168.50.12:8443:80"];
        volumes = ["/var/lib/vaultwarden:/data"];
        environment = {
          DOMAIN = "https://vaultwarden.deathraymind.net";
          SIGNUPS_ALLOWED = "true"; # Switch to "false" after setup
        };
        autoStart = true;
      };
    };
  };

  # --- SYSTEM NETWORKING & STORAGE ---
  networking.firewall = {
    allowedTCPPorts = [53 3000 80 443 853 8123];
    allowedUDPPorts = [53 5353];
  };
}
