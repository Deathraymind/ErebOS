{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.axiomos.stylix;
  themes = import ./themes.nix;
in {
  options.axiomos.stylix = {
    enable = lib.mkEnableOption "AxiomOS stylix Configuration";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
      description = "The name of the theme to use from themes.nix";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. System-wide Font Registration
    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only

        # --- THE FIX: Japanese/CJK Support ---
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];

      # This tells the system: "If JetBrains doesn't have it, use Noto CJK"
      fontconfig.defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font Mono" "Noto Sans Mono CJK JP"];
        sansSerif = ["JetBrainsMono Nerd Font" "Noto Sans CJK JP"];
        serif = ["JetBrainsMono Nerd Font" "Noto Serif CJK JP"];
      };
    };

    # 2. Home Manager configuration
    home-manager.users.deathraymind = {
      stylix.targets.kitty.enable = true;
      stylix.targets.firefox.enable = true;

      programs.kitty = {
        enable = true;
        # Force kitty to handle the fallback gracefully
        extraConfig = "symbol_map U+4E00-U+9FFF,U+3041-U+3096,U+30A1-U+30FC Noto Sans CJK JP";
      };
    };

    # 3. Main Stylix Configuration
    stylix = {
      image = ../home-manager/hyprland/godhands.jpg;
      base16Scheme = themes.${cfg.theme};
      enable = true;
      polarity = "dark";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 32;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        serif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sizes = {
          applications = 12;
          terminal = 12;
          popups = 10;
        };
      };
      targets = {
        console.enable = true;
        qt = {
          enable = true;
        };
      };
    };
  };
}
