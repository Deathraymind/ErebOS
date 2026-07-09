{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ErebOS.hyprpaper;
in {
  # 1. Option Definition
  options.ErebOS.hyprpaper = {
    enable = lib.mkEnableOption "ErebOS Hyprpaper Configuration";
  };

  # 2. Configuration Logic
  config = lib.mkIf cfg.enable {
    # Ensure the hyprpaper package is actually installed
    home.packages = [pkgs.hyprpaper];

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = ["${./godhands.jpg}"];
        wallpaper = [",${./godhands.jpg}"];
      };
    };

    # Tell Hyprland to start hyprpaper on login
    wayland.windowManager.hyprland.settings.exec-once = [
      "hyprpaper"
    ];
  };
}
