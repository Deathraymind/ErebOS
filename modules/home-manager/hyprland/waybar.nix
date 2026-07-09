{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ErebOS.waybar;

  # --- TWEAK THESE ---
  vars = {
    bg = "#${config.stylix.base16Scheme.base00}";
    text = "#${config.stylix.base16Scheme.base05}";
    border-color = "#${config.stylix.base16Scheme.base03}"; # rgba(${config.stylix.base16Scheme.base01}ff)
    radius = "15px";
    thickness = "1px";
    opacity = "0.9";
    font-size = "14px";
    accent = "#89B4FB";
    margin-top = "4px";
    margin-bottom = "0px";
  };

  # Helper for the border string
  border-style = "${vars.thickness} solid ${vars.border-color}";
in {
  options.ErebOS.waybar = {
    enable = lib.mkEnableOption "ErebOS waybar Compositer Config";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          exclusive = true;
          position = "top";
          passthrough = false;
          height = 20;
          gtk-layer-shell = true;
          modules-left = ["cpu" "battery" "memory"];
          modules-center = ["hyprland/workspaces" "clock" "custom/launcher"];
          modules-right = ["pulseaudio" "backlight" "tray" "custom/notifications"];

          "hyprland/workspaces" = {
            format = "{icon} {windows}";
            format-window-seperator = " ";
            window-rewrite-default = "";
            window-rewrite = {
              kitty = "";
              code = "󰨞";
            };
          };

          clock = {
            format = "{:%a, %e %b, %I:%M %p}";
            on-click = "firefox https://calendar.google.com";
          };

          cpu = {
            interval = 10;
            format = "  {usage}%";
            max-length = 10;
          };

          memory = {
            interval = 1;
            format = "  {used:.01f}G/{total:0.1f}G";
          };

          backlight = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = ["󰃞" "󰃟" "󰃠"];
            on-scroll-up = "brightnessctl set 5%+";
            on-scroll-down = "brightnessctl set 5%-";
            min-length = 6;
          };

          "custom/update" = {
            format = "󰚰";
            on-click = "kitty --title 'update' -e bash -c 'BOWOS_USER=bowyn sudo -E nixos-rebuild switch --impure --flake BowOS/.#kvm; echo -e \"\\n\\nPress any key to close\"; read -n 1'";
          };

          "custom/configure" = {
            format = "";
            on-click = "kitty -e bash -c 'cd BowOS && nvim configs/configuration.nix'";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            tooltip = false;
            format-muted = " Muted";
            on-click = "pavucontrol -t 3";
            on-scroll-up = "pamixer -i 5";
            on-scroll-down = "pamixer -d 5";
            scroll-step = 5;
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
          };

          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };
            format = "{icon}  {capacity}% ";
            format-charging = " {capacity}% ";
            format-plugged = " {capacity}% ";
            format-alt = "{time} {icon} ";
            format-icons = ["" "" "" "" ""];
          };

          tray = {
            icon-size = 24;
            spacing = 10;
          };

          "custom/notifications" = {
            format = "";
            on-click = "swaync-client -t";
          };

          "custom/launcher" = {
            format = "";
            on-click = "rofi -show run";
          };
        }
      ];

      style = ''
        * {
            border: none;
            border-radius: 0;
            font-family: "JetBrainsMono Nerd Font";
            font-weight: bold;
            font-size: ${vars.font-size};
            min-height: 20px;
            color: ${vars.text}; /* Add this line */
        }

        window#waybar {
            background: transparent;
            color: #cad3f5;
        }

        #tooltip {
            opacity: ${vars.opacity};
            background: ${vars.bg};
            border-radius: ${vars.radius};
            border-width: ${vars.thickness};
            border-style: solid;
        }

        #tray {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-top: ${border-style};
            border-bottom: ${border-style};
        }

        #tray:hover { background-color: ${vars.accent}; }

        #battery {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-top: ${border-style};
            border-bottom: ${border-style};
        }

        #memory {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-radius: 0px ${vars.radius} ${vars.radius} 0px;
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-right: ${border-style};

        }

        #pulseaudio {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-radius: ${vars.radius} 0px 0px ${vars.radius};
            transition: background-color 0.3s ease;
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-left: ${border-style};
        }

        #pulseaudio:hover { background-color: ${vars.accent}; }

        #backlight {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            transition: background-color 0.3s ease;
            border-top: ${border-style};
            border-bottom: ${border-style};
        }
        #backlight:hover { background-color: ${vars.accent}; }

        #custom-update {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-radius: 0px ${vars.radius} ${vars.radius} 0px;
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-right: ${border-style};
        }
        #custom-update:hover { background-color: ${vars.accent}; }

        #custom-configure {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-top: ${border-style};
            border-bottom: ${border-style};
        }
        #custom-configure:hover { background-color: ${vars.accent}; }

        #cpu {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            margin-left: 8px;
            border-radius: ${vars.radius} 0px 0px ${vars.radius};
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-left: ${border-style};
        }

        #clock {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-top: ${border-style};
            border-bottom: ${border-style};
        }

        #custom-notifications {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            margin-right: 8px;
            border-radius: 0px ${vars.radius} ${vars.radius} 0px;
            transition: background-color 0.3s ease;
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-right: ${border-style};
        }
        #custom-notifications:hover { background-color: ${vars.accent}; }

        #custom-launcher {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-radius: 0px ${vars.radius} ${vars.radius} 0px;
            border-right: ${border-style};
            border-top: ${border-style};
            border-bottom: ${border-style};
            transition: background-color 0.3s ease;
        }
        #custom-launcher:hover { background-color: ${vars.accent}; }

        #workspaces {
            background: ${vars.bg};
            opacity: ${vars.opacity};
            padding: 0px 10px;
            margin-top: ${vars.margin-top};
            margin-bottom: ${vars.margin-bottom};
            border-radius: ${vars.radius} 0px 0px ${vars.radius};
            border-top: ${border-style};
            border-bottom: ${border-style};
            border-left: ${border-style};
        }
        #workspaces button label {
            font-size: ${vars.font-size};
        }
        #workspaces button:hover { background-color: ${vars.accent}; }
      '';
    };
    wayland.windowManager.hyprland.settings.exec-once = [
      "waybar"
    ];
  };
}
