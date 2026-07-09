{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "deathraymind";
  home.homeDirectory = "/home/deathraymind";

  home.stateVersion = "25.11"; # Please read the comment before changing.

  imports = [
    ../../modules/home-manager/default.nix
  ];
  stylix.enable = true;
  ErebOS.hyprland.enable = false;
  ErebOS.homeNiri.enable = true;
  ErebOS.homeNoctalia.enable = true;
  ErebOS.hyprspace.enable = false;
  ErebOS.hyprpaper.enable = false;
  ErebOS.hyprpanel.enable = false;
  ErebOS.homeStylix.enable = true;
  ErebOS.waybar.enable = true;
  ErebOS.hyprbar.enable = false;

  ErebOS.git.enable = true;
  ErebOS.zsh.enable = true;
  ErebOS.kitty.enable = true;
  ErebOS.rofi.enable = true;
  ErebOS.starship.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
