{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ErebOS.starship;
  # Pull the Oxocarbon colors from Stylix
  # base0D = blue/cyan, base0E = purple, base0C = teal/aqua, base08 = pink
  colors = {
    user_bg = "#${config.stylix.base16Scheme.base09}";
    dir_bg = "#${config.stylix.base16Scheme.base05}";
    git_bg = "#${config.stylix.base16Scheme.base0E}";
    lang_bg = "#${config.stylix.base16Scheme.base02}";
    time_bg = "#${config.stylix.base16Scheme.base0F}";
    text_dark = "#${config.stylix.base16Scheme.base00}";
  };
in {
  options.ErebOS.starship = {
    enable = lib.mkEnableOption "ErebOS starship Configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;

        # Using the Nerd Font Powerline symbols with Stylix colors
        format = lib.concatStrings [
          "[](${colors.user_bg})"
          "$username"
          "[](bg:${colors.dir_bg} fg:${colors.user_bg})"
          "$directory"
          "[](fg:${colors.dir_bg} bg:${colors.git_bg})"
          "$git_branch$git_status"
          "[](fg:${colors.git_bg} bg:${colors.lang_bg})"
          "$c$elixir$elm$golang$haskell$java$julia$nodejs$nim$rust"
          "[](fg:${colors.lang_bg} bg:${colors.time_bg})"
          "$time"
          "[](fg:${colors.time_bg})"
        ];

        username = {
          show_always = true;
          style_user = "bg:${colors.user_bg} fg:${colors.text_dark} bold";
          style_root = "bg:${colors.user_bg} fg:${colors.text_dark} bold";
          format = "[$user ]($style)";
        };

        directory = {
          style = "bg:${colors.dir_bg} fg:${colors.text_dark} bold";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "Documents";
            "Downloads" = "Downlaods";
            "Music" = "Music";
            "Pictures" = "Pictures";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:${colors.git_bg} fg:${colors.text_dark}";
          format = "[[ $symbol $branch ](bg:${colors.git_bg})]($style)";
        };

        git_status = {
          style = "bg:${colors.git_bg} fg:${colors.text_dark}";
          format = "[[($all_status$ahead_behind )](bg:${colors.git_bg})]($style)";
        };

        # Language blocks using the darker gray pill
        rust = {
          symbol = "🦀";
          style = "bg:${colors.lang_bg}";
          format = "[[ $symbol ($version) ]($style)]";
        };
        nodejs = {
          symbol = " ";
          style = "bg:${colors.lang_bg}";
          format = "[[ $symbol ($version) ]($style)]";
        };
        golang = {
          symbol = " ";
          style = "bg:${colors.lang_bg}";
          format = "[[ $symbol ($version) ]($style)]";
        };

        time = {
          disabled = true;
          time_format = "%R";
          style = "bg:${colors.time_bg} fg:${colors.text_dark}";
          format = "[[  $time ](bg:${colors.time_bg})]($style)";
        };
      };
    };
  };
}
