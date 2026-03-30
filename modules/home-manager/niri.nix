{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.axiomos.niri;
in {
  options.axiomos.niri = {
    enable = lib.mkEnableOption "AxiomOS Niri Composite Config";
  };

  config = lib.mkIf cfg.enable {
    # Niri doesn't include these by default, keeping your Hyprland tools
    home.packages = with pkgs; [
      kitty
      wl-color-picker
      playerctl
      brightnessctl
      rofi-wayland # Niri works great with rofi-wayland
    ];

    # Using the niri-flake (recommended for the latest features)
    # Ensure inputs.niri is in your flake.nix
    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri;

      settings = {
        # --- INPUT & SENSITIVITY ---
        input = {
          keyboard.repeat-delay = 250;
          keyboard.repeat-rate = 30;
          touchpad.natural-scroll = true;
        };

        # --- OUTPUTS (Mapped from your Hyprland config) ---
        outputs = {
          "DP-1" = {
            mode = {
              width = 2560;
              height = 1440;
              refresh = 165.0;
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
          "eDP-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            position = {
              x = 0;
              y = 0;
            };
          };
        };

        # --- LAYOUT & STYLING ---
        layout = {
          gaps = 4;
          default-column-width = {proportion = 0.8;}; # Similar to your mfact = 0.8
          focus-ring = {
            enable = true;
            width = 1;
            # Pulling from your Stylix/Base16 colors
            active.color = "rgba(${config.stylix.base16Scheme.base03}ff)";
            inactive.color = "rgba(${config.stylix.base16Scheme.base01}ff)";
          };
          struts = {
            left = 0;
            right = 0;
            top = 0;
            bottom = 0;
          };
        };

        # --- WINDOW RULES (Kitty Floating/Centered) ---
        window-rules = [
          {
            matches = [{app-id = "^kitty$";}];
            open-floating = true;
            default-column-width = {fixed = 800;};
            default-window-height = {fixed = 600;};
          }
        ];

        # --- KEYBINDS (Mapped to your SUPER/CTRL/ALT logic) ---
        binds = with config.lib.niri.actions; {
          # Apps & Essentials
          "Super+A".action = spawn "rofi" "-show" "drun";
          "Super+P".action = spawn "hypersnip";
          "Super+Q".action = close-window;
          "Super+W".action = toggle-window-floating;
          "Alt+Return".action = maximize-column; # Niri's "fullscreen" is usually column maximize
          "Super+T".action = spawn "kitty";
          "Super+I".action = spawn "wl-color-picker";

          # --- COLUMN/WINDOW MOVEMENT (The Niri way) ---
          "Super+Left".action = focus-column-left;
          "Super+Right".action = focus-column-right;
          "Super+H".action = focus-column-left;
          "Super+L".action = focus-column-right;
          "Super+K".action = focus-window-or-workspace-up;
          "Super+J".action = focus-window-or-workspace-down;

          # Moving windows within the "ribbon"
          "Super+Shift+Ctrl+Left".action = move-column-left;
          "Super+Shift+Ctrl+Right".action = move-column-right;
          "Super+Shift+Ctrl+H".action = move-column-left;
          "Super+Shift+Ctrl+L".action = move-column-right;

          # Workspace Navigation (Niri uses vertical workspaces)
          "Super+Ctrl+Left".action = focus-workspace-up;
          "Super+Ctrl+Right".action = focus-workspace-down;

          # Multimedia (bindl equivalent)
          "XF86AudioPlay".action = spawn "playerctl" "play-pause";
          "XF86AudioNext".action = spawn "playerctl" "next";
          "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "5%+";
          "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_SINK@" "5%+";
        };
      };
    };
  };
}
