# hyprpanel.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  # This makes it easier to reference your own toggle
  cfg = config.axiomos.hyprland;
in {
  ### 1. Define the "Switch"
  options.axiomos.hyprpanel = {
    enable = lib.mkEnableOption "AxiomOS hyprpanel Composite Config";
  };

  ### 2. The Logic (Only applies if enable is true)
  config = lib.mkIf cfg.enable {
    # 1. Install xdg-utils (provides the actual 'xdg-open' command)
    home.packages = [pkgs.xdg-utils];

    # 2. Configure Portals
    # This allows apps to communicate (opening files, screensharing, etc.)
    programs.hyprpanel = {
      enable = true;

      # The 'overlay.enable' and 'layout' options are likely gone
      # from the HM module to prevent recursion errors.
      # We now pass everything through the 'settings' or 'extraConfig' attributes.

      settings = {
        theme.bar.transparent = true;

        # This is the new way to define layout in the official module
        "bar.layouts" = {
          "0" = {
            left = ["dashboard" "workspaces" "windowtitle"];
            middle = ["media"];
            right = ["volume" "network" "bluetooth" "battery" "clock" "notifications"];
          };
        };

        # Your other settings
        bar.launcher.auto_icon = true;
        menus.clock.time.military = true;
        menus.dashboard.stats.enable_gpu = false;
        programs.hyprshot = {
          enable = true;
          saveLocation = "$HOME/Pictures/Screenshots";
        };
      };
    };
    wayland.windowManager.hyprland.settings.exec-once = [
      # "hyprpanel"
    ];
  };
}
