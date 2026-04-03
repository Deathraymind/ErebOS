# homeStylix.nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Enable libvirtd daemon
  virtualisation.libvirtd.enable = true;

  # Install virt-manager
  programs.virt-manager.enable = true;
  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };
  ### 2. The Logic
  environment.systemPackages = [
    pkgs.virt-manager
    pkgs.qemu
    pkgs.libvirt
    pkgs.ffmpeg-full
    pkgs.yazi
  ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
    ];
}
