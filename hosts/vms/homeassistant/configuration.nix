{
  pkgs,
  config,
  lib,
  ...
}: {
  services.sshd.enable = true;
  imports = [];
  virtualisation.diskSize = lib.mkForce 30480;
  # --- USER CONFIGURATION ---
  users.users.deathraymind = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = ["wheel" "nextcloud"];
    hashedPassword = "$6$X6ADCAYJr36.atJY$aOzF6Drf0YEq2ac3QnFFU3bhJZNuY/hX9Fux6dcJCeiQTNBK1F3oFKqqlhpUoKVJA34gfIWs0VkcO1051jn5d0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1p2OamHpIwYUh0mS3yj/CDmT01n4leoYCd/tuqMJHt deathraymind@gmail.com"
    ];
  };
  services.esphome = {
    enable = true;
    address = "192.168.20.2";
    openFirewall = true;
  };
  # --- CONTAINERS CONFIGURATION ---
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        volumes = [
          "/var/lib/hass:/config"
          "/run/dbus:/run/dbus:ro" # Bluetooth via host dbus
          "/etc/localtime:/etc/localtime:ro"
        ];
        ports = [
          "5353:5353/tcp"
          "192.168.20.2:8123:8123" # bind to the net20 IP specifically
        ];

        environment = {
          TZ = "Asia/Tokyo";
        };
        extraOptions = [
          # "--device=/dev/ttyUSB0"  # uncomment if you have a Zigbee/Z-Wave stick
        ];
        autoStart = true;
      };
    };
  };

  # --- SYSTEM NETWORKING & STORAGE ---
  networking.firewall = {
    allowedTCPPorts = [8123];
    allowedUDPPorts = [];
  };
}
