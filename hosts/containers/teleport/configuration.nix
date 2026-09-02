{...}: {
  services.teleport = {
    enable = true;
    settings = {
      version = "v3";
      teleport = {
        nodename = "teleport-server";
        data_dir = "/var/lib/teleport";
      };
      auth_service = {
        enabled = true;
        cluster_name = "homelab";
        listen_addr = "127.0.0.1:3025";
        proxy_listener_mode = "multiplex";
      };
      proxy_service = {
        enabled = true;
        web_listen_addr = "0.0.0.0:443";
        public_addr = ["teleport.home.arpa:443" "192.168.1.11:443"];
      };
      ssh_service.enabled = true;
    };
  };
}
