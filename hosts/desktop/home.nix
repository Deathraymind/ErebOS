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
  axiomos.hyprland.enable = true;
  axiomos.homeNiri.enable = true;
  axiomos.homeNoctalia.enable = true;
  axiomos.hyprspace.enable = false;
  axiomos.hyprpaper.enable = false;
  axiomos.hyprpanel.enable = false;
  axiomos.homeStylix.enable = true;
  axiomos.waybar.enable = true;
  axiomos.hyprbar.enable = false;

  axiomos.git.enable = true;
  axiomos.zsh.enable = true;
  axiomos.kitty.enable = true;
  axiomos.rofi.enable = true;
  axiomos.starship.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
