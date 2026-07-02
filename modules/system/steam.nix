# homeStylix.nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.axiomos.steam;
in {
  imports = [
  ];

  ### 1. Define the "Switch"
  options.axiomos.steam = {
    enable = lib.mkEnableOption "AxiomOS steam Configuration";
  };

  ### 2. The Logic
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.adwsteamgtk
      pkgs.prismlauncher
      pkgs.unityhub
    ];
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
        "unityhub"
        "corefonts"
      ];
    hardware.steam-hardware.enable = true;
    programs.steam = {
      enable = true;
    };
  };
}
