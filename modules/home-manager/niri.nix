{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.axiomos.homeNiri;
in {
  imports = [
    inputs.niri.homeModules.niri
  ];

  ### 1. Define the "Switch"
  options.axiomos.homeNiri = {
    enable = lib.mkEnableOption "AxiomOS Niri Compositor Configuration";
  };

  ### 2. The Logic
  config = lib.mkIf cfg.enable {
    # Import the Niri flake module only when enabled
    home.packages = with pkgs; [
      xwayland-satellite
    ];
    # Apply the check override
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
          {command = ["${pkgs.swww}/bin/swww-daemon"];}
          {command = ["noctalia-shell"];}
          {
            command = [
              "${pkgs.swww}/bin/swww"
              "img"
              "/home/deathraymind/AxiomOS/modules/home-manager/hyprland/godhands.jpg"
            ];
          }
        ];

        input = {
          keyboard.xkb.layout = "us";

          focus-follows-mouse = {
            enable = true;
            # This is the "Goldilocks" setting.
            # "10%" means it only peeks at the next window instead of
            # yeeting your whole view instantly.
            # Set to "0%" to completely stop edge-scrolling while
            # keeping mouse-focus enabled.
            max-scroll-amount = "10%";
          };

          # To prevent accidental 'warping' when you switch windows:
          warp-mouse-to-focus = true;
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
          gaps = 12;
          struts = {
            left = 12;
            right = 12;
            top = 12;
            bottom = 12;
          };
          border = {
            enable = true;
            width = 1;
            active.color = "#${config.lib.stylix.colors.base03}"; # Note: used config.lib.stylix for safety
            inactive.color = "#${config.lib.stylix.colors.base01}";
          };
          focus-ring = {
            enable = true;
            width = 1;
            active.color = "#${config.lib.stylix.colors.base03}";
            inactive.color = "#${config.lib.stylix.colors.base01}";
          };
        };

        window-rules = [
          {
            matches = []; # Empty matches applies to all windows
            draw-border-with-background = false;
          }
          {
            matches = [];
            geometry-corner-radius = {
              top-left = 12.0;
              top-right = 12.0;
              bottom-left = 12.0;
              bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
        ];

        binds = {
          "Mod+O".action.toggle-overview = [];
          "Mod+T".action.spawn = ["kitty"];
          "Mod+Q".action.close-window = [];
          "Mod+A".action.spawn = ["rofi" "-show" "drun"];
          "Mod+P".action.spawn = ["hypersnip"];
          "Mod+W".action.toggle-window-floating = [];
          "Mod+I".action.spawn = ["wl-color-picker"];
          "Alt+Return".action.maximize-column = [];
          "Mod+Shift+F".action.fullscreen-window = [];
          "Mod+H".action.focus-column-left = [];
          "Mod+L".action.focus-column-right = [];
          "Mod+K".action.focus-window-or-workspace-up = [];
          "Mod+J".action.focus-window-or-workspace-down = [];
          "XF86AudioPlay".action.spawn = ["playerctl" "play-pause"];
          "XF86AudioNext".action.spawn = ["playerctl" "next"];
          "XF86MonBrightnessUp".action.spawn = ["brightnessctl" "set" "5%+"];
          "XF86AudioRaiseVolume".action.spawn = ["wpctl" "set-volume" "-l" "1.0" "@DEFAULT_SINK@" "5%+"];
        };
      };
    };
  };
}
