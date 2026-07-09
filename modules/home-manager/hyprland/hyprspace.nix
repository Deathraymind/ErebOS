{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.ErebOS.hyprspace;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.ErebOS.hyprspace = {
    enable = lib.mkEnableOption "ErebOS hyprspace Configuration";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      plugins = [
        inputs.hyprspace.packages.${pkgs.system}.Hyprspace
      ];

      settings = {
        bind = [
          "SUPER, Tab, overview:toggle,"
        ];
      };
    };
  };
}
