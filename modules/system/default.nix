{...}: {
  imports = [
    ./desktop-logic.nix
    ./steam.nix
    ./stylix.nix
    ./applications/defaultApplications.nix
    ./applications/screenshot.nix
    ./cachy.nix
    ./autologin.nix
  ];
}
