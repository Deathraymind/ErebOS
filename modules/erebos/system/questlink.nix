{config, ...}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [config.sops.secrets."questlink-env".path];

    profiles.questlink = {
      connection = {
        id = "questlink";
        type = "wifi";
        interface-name = "wlp7s0";
        autoconnect = false;
      };
      wifi = {
        mode = "ap";
        ssid = "questlink";
        band = "a";
        channel = 149;
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        proto = "rsn";
        pairwise = "ccmp";
        group = "ccmp";
        psk = "$QUESTLINK_PSK";
      };
      ipv4.method = "shared";
      ipv6.method = "disabled";
    };
  };

  sops.secrets."questlink-env" = {};

  networking.firewall.trustedInterfaces = ["wlp7s0"];
}
