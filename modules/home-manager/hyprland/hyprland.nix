{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.ErebOS.hyprland;
in {
  options.ErebOS.hyprland = {
    enable = lib.mkEnableOption "ErebOS Hyprland Composite Config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
      wl-color-picker
      playerctl
      brightnessctl
    ];

    wayland.windowManager.hyprland = {
      package = lib.mkForce inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      enable = true;
      systemd.enable = false;

      settings = {
        animations = {
          enabled = true;
          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "smooth, 0.87,0.39,1,0.81"
          ];
          animation = [
            "windows, 1, 3, smooth, slide top"
            "fade, 1, 3, default"
            "windowsOut, 1, 3, smooth, slide bottom"
            "border, 1, 3, default"
            "workspaces, 1, 3, default"
          ];
        };

        bind = [
          # Apps & Essentials
          "SUPER, A, exec, rofi -show drun"
          "SUPER, P, exec, hypersnip"
          "SUPER, Q, killactive,"
          "SUPER, W, togglefloating,"
          "ALT, return, fullscreen,"
          "SUPER, T, exec, kitty"
          "SUPER, I, exec, wl-color-picker"

          # --- WORKSPACES (Stay on current monitor) ---
          # Switch view to next/prev workspace on THIS monitor
          "SUPER CTRL, right, workspace, r+1"
          "SUPER CTRL, left,  workspace, r-1"
          "SUPER CTRL, L,     workspace, r+1"
          "SUPER CTRL, H,     workspace, r-1"

          # Move window to next/prev workspace on THIS monitor
          "SUPER CTRL ALT, right, movetoworkspace, r+1"
          "SUPER CTRL ALT, left,  movetoworkspace, r-1"
          "SUPER CTRL ALT, L,     movetoworkspace, r+1"
          "SUPER CTRL ALT, H,     movetoworkspace, r-1"

          # --- WINDOW MOVEMENT (Inside the current workspace) ---
          "SUPER SHIFT CONTROL, left,  movewindow, l"
          "SUPER SHIFT CONTROL, right, movewindow, r"
          "SUPER SHIFT CONTROL, up,    movewindow, u"
          "SUPER SHIFT CONTROL, down,  movewindow, d"
          "SUPER SHIFT CONTROL, H,     movewindow, l"
          "SUPER SHIFT CONTROL, L,     movewindow, r"
          "SUPER SHIFT CONTROL, K,     movewindow, u"
          "SUPER SHIFT CONTROL, J,     movewindow, d"

          # --- FOCUS MOVEMENT ---
          "SUPER, left,  movefocus, l"
          "SUPER, right, movefocus, r"
          "SUPER, up,    movefocus, u"
          "SUPER, down,  movefocus, d"
          "SUPER, H,     movefocus, l"
          "SUPER, L,     movefocus, r"
          "SUPER, K,     movefocus, u" # Fixed: Was 'u' in your config
          "SUPER, J,     movefocus, d" # Fixed: Was 'u' in your config
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, X, resizewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindl = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", xf86monbrightnessup, exec, brightnessctl set 5%+"
          ", xf86audioraisevolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"
        ];

        monitor = [
          "DP-1, 2560x1440@165, 0x0, 1"
          "HDMI-A-1, 1920x1080@70, -1920x0, 1"
          "Virtual-1, 1920x1080@60, 0x0, 1"
          "eDP-1, 1920x1080@60, 0x0, 1"
        ];

        master = {
          new_status = "master";
          mfact = 0.80;
          special_scale_factor = 0.8;
        };
        windowrule = lib.mkForce [
          "match:class ^(kitty)$, float on"

          "match:class ^(kitty)$, size 800 600"

          "match:class ^(kitty)$ , center 1"

          "match:class ^(kitty)$, pin on"
        ];
        general = {
          gaps_in = 4;
          gaps_out = 4;
          border_size = 1;
          layout = "master";
          "col.active_border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base03}ff)";
          "col.inactive_border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base01}ff)";
          resize_on_border = true;
          extend_border_grab_area = 20;
          hover_icon_on_border = true;
        };

        decoration = {
          rounding = 15;
          shadow = {
            enabled = true;
            range = 8;
            render_power = 4;
            offset = "5 5";
            color = lib.mkForce "rgba(00000066)";
          };
        };
      };
    };
  };
}
