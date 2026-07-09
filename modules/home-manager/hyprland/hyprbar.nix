{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.ErebOS.hyprbar;
in {
  ### 1. Define the "Switch"
  options.ErebOS.hyprbar = {
    enable = lib.mkEnableOption "ErebOS Hyprbar Configuration";
  };

  ### 2. The Logic
  config = lib.mkIf cfg.enable {
    # Required for your minimize/maximize scripts to work
    home.packages = [pkgs.jq];

    wayland.windowManager.hyprland = {
      plugins = [
        inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      ];

      settings = {
        "plugin:hyprbars" = {
          bar_height = 16;
          bar_color = "0xee1e1e2e";
          "col.text" = "0xffcdd6f4";
          bar_text_font = "Sans";
          bar_text_size = 12;
          bar_part_of_window = true;

          hyprbars-button = let
            closeAction = "hyprctl dispatch killactive";

            # Minimize logic scripts
            isOnSpecial = "hyprctl activewindow -j | jq -re 'select(.workspace.name == \"special\")' >/dev/null";
            moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
            moveToActive = "hyprctl dispatch movetoworkspacesilent name:$(hyprctl -j activeworkspace | jq -re '.name')";

            minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";
            maximizeAction = "hyprctl dispatch togglefloating";
          in [
            "rgb(f38ba8), 12, , ${closeAction}"
            "rgb(f9e2af), 12, , ${minimizeAction}"
            "rgb(a6e3a1), 12, , ${maximizeAction}"
          ];
        };
      };
    };
  };
}
