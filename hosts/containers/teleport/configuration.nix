{...}: {
  services.teleport = {
    insecure.enable = true;
    enable = true;
    settings = {
      app_service = {
        enabled = true;
        apps = [
          # web consoles (HTTP apps)
          {
            name = "idrac-r640";
            uri = "https://192.168.1.137";
            insecure_skip_verify = true;
          }
          {
            name = "ilo-dl380";
            uri = "https://10.0.10.51";
            insecure_skip_verify = true;
          }
          {
            name = "cimc-ucs-1";
            uri = "https://192.168.1.220";
            insecure_skip_verify = true;
          }

          # SSH CLIs (TCP apps)
          {
            name = "idrac-r640-ssh";
            uri = "tcp://192.168.1.137:22";
          }
          {
            name = "sw-core-ssh";
            uri = "tcp://10.0.10.2:22";
          }
        ];
      };

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
