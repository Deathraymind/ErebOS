{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
  ];

  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      spawn-at-startup = [
        # This starts the "engine"
        {command = ["${pkgs.swww}/bin/swww-daemon"];}

        # This actually paints the picture
        {
          command = [
            "${pkgs.swww}/bin/swww"
            "img"
            "/home/deathraymind/AxiomOS/modules/home-manager/hyprland/godhands.jpg"
          ];
        }
      ];
      # ... rest of your settings
      input = {
        keyboard.xkb.layout = "us";
        focus-follows-mouse.enable = true;
      };

      outputs = {
        "DP-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 164.998;
          };
          position = {
            x = 0;
            y = 0;
          };
        };
        "HDMI-A-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 70.0;
          };
          position = {
            x = -1920;
            y = 0;
          };
        };
      };

      layout = {
        gaps = 8;
        # These match your Hyprland decoration preferences
        border = {
          enable = true;
          width = 1;
          # Matching your Hyprland col.active_border (base03)
          active.color = "#${config.stylix.base16Scheme.base03}";
          # Matching your Hyprland col.inactive_border (base01)
          inactive.color = "#${config.stylix.base16Scheme.base01}";
        };
        focus-ring = {
          enable = true;
          width = 1;
          active.color = "#${config.stylix.base16Scheme.base03}";
          inactive.color = "#${config.stylix.base16Scheme.base01}";
        };
      };
      window-rules = [
        {
          # Empty matches means it applies to EVERY window
          matches = [];

          # This must be a block, not just a number
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };

          clip-to-geometry = true;
        }
      ]; # Window Rules for Kitty (Floating & Size)

      binds = {
        # --- Overview (Commented out until we find your version's command) ---
        "Mod+O".action.toggle-overview = [];

        # --- Apps ---
        "Mod+T".action.spawn = ["kitty"];
        "Mod+Q".action.close-window = [];
        "Mod+A".action.spawn = ["rofi" "-show" "drun"];
        "Mod+P".action.spawn = ["hypersnip"];
        "Mod+W".action.toggle-window-floating = [];
        "Mod+I".action.spawn = ["wl-color-picker"];

        # --- Layout Controls ---
        "Alt+Return".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];

        # --- Navigation ---
        "Mod+H".action.focus-column-left = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+K".action.focus-window-or-workspace-up = [];
        "Mod+J".action.focus-window-or-workspace-down = [];

        # --- Media ---
        "XF86AudioPlay".action.spawn = ["playerctl" "play-pause"];
        "XF86AudioNext".action.spawn = ["playerctl" "next"];
        "XF86MonBrightnessUp".action.spawn = ["brightnessctl" "set" "5%+"];
        "XF86AudioRaiseVolume".action.spawn = ["wpctl" "set-volume" "-l" "1.0" "@DEFAULT_SINK@" "5%+"];
      };
    };
  };
}
