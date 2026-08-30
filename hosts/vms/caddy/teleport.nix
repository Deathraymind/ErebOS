{
  pkgs,
  config,
  ...
}: {
  sops.secrets.teleport_node_token = {
    sopsFile = ../secrets/teleport.yaml;
    restartUnits = ["teleport.service"]; # roll the node if the token changes
    # default owner root:root, mode 0400 — fine, teleport runs as root
  };
  services.teleport = {
    enable = true;
    settings = {
      version = "v3";
      teleport = {
        nodename = "caddy"; # <- per host
        proxy_server = "192.168.1.11:443";
        auth_token = "/run/secrets/teleport_node_token"; # sops drops this
        ca_pin = "sha256:3b9c1a57f9ffb07930428c633643e69fef6a9bec299c10ec91dcfdc6beee6dae"; # from tctl status; inline ok
      };
      auth_service.enabled = false;
      proxy_service.enabled = false;
      ssh_service = {
        enabled = true;
        labels = {env = "homelab";}; # optional, for RBAC/filtering
      };
    };
    # no firewall ports — the node only dials out
  };
}
