{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.axiomos.autologin;
in {
  ### 1. Define the "Switch"
  options.axiomos.autologin = {
    enable = lib.mkEnableOption "AxiomOS autologin Configuration";
  };

  ### 2. The Logic
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Replace 'yourusername' with your actual NixOS username
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'niri'";
          user = "deathraymind";
        };
      };
    };

    # This helps tuigreet look clean on boot
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Logs errors to journalctl if things break
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
