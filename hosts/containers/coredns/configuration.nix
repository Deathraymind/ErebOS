{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix" # boot.isContainer, no bootloader/fstab
  ];
  services.resolved.enable = false;
  nix.settings.trusted-users = ["root" "@wheel"];

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

  # --- DNS ---
  services.coredns = {
    enable = true;
    config = ''
      home.arpa {
        hosts {
          192.168.1.10  caddy.home.arpa
          192.168.1.11  teleport.home.arpa
          192.168.1.50  pelican.home.arpa
          192.168.1.51  pelican-wings.home.arpa
          192.168.1.53  vaultwarden.home.arpa
          ttl 60
        }
      }

      . {
        forward . 1.1.1.1 9.9.9.9
        cache 30
        log
        errors
      }
    '';
  };
  # --- System ---
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05";
}
