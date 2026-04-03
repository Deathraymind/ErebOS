{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.axiomos.homeNoctalia;
in {
  ### 1. Imports must be at the top level
  imports = [
    inputs.noctalia.homeModules.default
  ];

  ### 2. Define the "Switch"
  options.axiomos.homeNoctalia = {
    enable = lib.mkEnableOption "AxiomOS Noctalia Shell Configuration";
  };

  ### 3. The Logic
  config = lib.mkIf cfg.enable {
    # No imports allowed here!

    programs.noctalia-shell = {
      enable = true;
      settings = {
        bar = {
          position = "top";
        };
      };
    };
  };
}
