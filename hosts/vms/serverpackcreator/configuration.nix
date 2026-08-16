{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.services.docker-serverpackcreator-db = {
    after = ["run-secrets.mount" "sops-nix.service"];
    wants = ["sops-nix.service"];
  };
  virtualisation.diskSize = lib.mkForce 30480;

  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
      dns = ["1.1.1.1" "8.8.8.8"];
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
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

  users.users.bowyn = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
  };

  # --- SOPS SECRETS ---
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # --- SERVERPACKCREATOR (web) ---
  # SPC needs both containers on a shared user-defined network so docker's
  # embedded DNS can resolve the DB by name. The default bridge won't do that.
  systemd.services.init-spc-network = {
    description = "Create serverpackcreator docker network";
    after = ["docker.service"];
    requires = ["docker.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect spc >/dev/null 2>&1 \
        || ${pkgs.docker}/bin/docker network create spc
    '';
  };

  systemd.services.docker-serverpackcreator-db = {
    after = ["init-spc-network.service"];
    requires = ["init-spc-network.service"];
  };
  systemd.services.docker-serverpackcreator = {
    after = ["init-spc-network.service"];
    requires = ["init-spc-network.service"];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/serverpackcreator            0750 1000 1000 -"
    "d /var/lib/serverpackcreator/modpacks   0750 1000 1000 -"
    "d /var/lib/serverpackcreator/server-packs 0750 1000 1000 -"
    "d /var/lib/serverpackcreator/logs       0750 1000 1000 -"
  ];

  # One SOPS secret whose *value* is a KEY=VALUE env file. Goes to both
  # containers via environmentFiles — NOT `environment`, because oci-container
  # `environment` values get baked into the systemd unit / world-readable store.
  sops.secrets."spc/env" = {
    sopsFile = ../../../secrets/pelican.yaml;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      serverpackcreator-db = {
        image = "mongo:4.4";
        extraOptions = ["--network=spc"];
        environment.MONGO_INITDB_DATABASE = "serverpackcreatordb";
        environmentFiles = [config.sops.secrets."spc/env".path];
        volumes = [
          # grab this file from the repo (docker/init-mongo.js) and drop it here —
          # it creates SPC's app user *inside* serverpackcreatordb, else auth fails
          "/var/lib/serverpackcreator/init-mongo.js:/docker-entrypoint-initdb.d/init.js:ro"
          "spcdb-data:/data/db"
          "spcdb-conf:/data/configdb"
        ];
      };
      serverpackcreator = {
        image = "griefed/serverpackcreator:6.7.0"; # pin a real tag, not :latest
        extraOptions = ["--network=spc"];
        dependsOn = ["serverpackcreator-db"];
        environment = {
          TZ = "Asia/Tokyo";
          PUID = "1000";
          PGID = "1000";
          SPC_DATABASE_HOST = "serverpackcreator-db";
          SPC_DATABASE_PORT = "27017";
          SPC_DATABASE_DB = "serverpackcreatordb";
        };
        environmentFiles = [config.sops.secrets."spc/env".path];
        ports = ["8080:8080"]; # localhost only — reverse-proxy w/ auth
        volumes = [
          "/var/lib/serverpackcreator/modpacks:/app/serverpackcreator/modpacks"
          "/var/lib/serverpackcreator/server-packs:/app/serverpackcreator/server-packs"
          "/var/lib/serverpackcreator/logs:/app/serverpackcreator/logs"
        ];
      };
    };
  };
}
