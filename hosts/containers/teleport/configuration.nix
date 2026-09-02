{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix" # boot.isContainer, no bootloader/fstab
  ];

  # --- Access ---
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.deathraymind = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1p2OamHpIwYUh0mS3yj/CDmT01n4leoYCd/tuqMJHt deathraymind@gmail.com"
    ];
    hashedPassword = "$6$X6ADCAYJr36.atJY$aOzF6Drf0YEq2ac3QnFFU3bhJZNuY/hX9Fux6dcJCeiQTNBK1F3oFKqqlhpUoKVJA34gfIWs0VkcO1051jn5d0";
  };

  services.teleport = {
    enable = true;

    settings = {
      version = "v3";
      teleport = {
        nodename = "teleport-server"; # this box's name
        data_dir = "/var/lib/teleport";
      };
      auth_service = {
        enabled = true;
        cluster_name = "homelab"; # still permanent, still can't rename
        listen_addr = "127.0.0.1:3025"; # auth stays loopback-only
        proxy_listener_mode = "multiplex";
      };
      proxy_service = {
        enabled = true;
        web_listen_addr = "0.0.0.0:443"; # or bind your tailscale IP specifically
        public_addr = ["teleport.home.arpa:443" "192.168.1.11:443"]; # whatever you'll type in tsh --proxy
      };
      ssh_service.enabled = true;
    };
  };

  # --- System ---
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05";
}
