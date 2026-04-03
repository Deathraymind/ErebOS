{
  lib,
  config,
  ...
}: let
  cfg = config.axiomos.kitty;
in {
  ### 1. Define the "Switch"
  options.axiomos.kitty = {
    enable = lib.mkEnableOption "AxiomOS kitty Configuration";
  };

  ### 2. The Logic
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        background_opacity = lib.mkForce "0.9"; # 0.0 is transparent, 1.0 is opaque
        dynamic_background_opacity = true; # Allows changing opacity at runtime
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        cursor_trail_start_threshold = 2;
      };
    };
  };
}
