{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "AxiomOS";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [pkgs.networkmanager-openvpn];
  time.timeZone = "Japan/Tokyo";

  users.mutableUsers = false;
  users.users.deathraymind = {
    hashedPassword = "$y$j9T$Yu6LVySFa46PsKBHC7lkI.$fCdSJMULL1L2uOMhiY1WlR5QzW84qP42ktl2CxvSkgC";
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      neovim
    ];
  };

  ## Home Manager Import ##
  axiomos.steam.enable = true;

  virtualisation.vmVariant = {
    # Taken from https://github.com/donovanglover/nix-config/commit/0bf134297b3a62da62f9ee16439d6da995d3fbff
    # to enable Hyprland to work on a virtualized GPU.
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display"
      "gtk,gl=on,grab-on-hover=on"
      "-device"
      "usb-tablet"
      "-device"
      "usb-kbd"
      # Wire up pipewire audio
      "-audiodev pipewire,id=audio0"
      "-device intel-hda"
      "-device hda-output,audiodev=audio0"
      # to enable the vm to grab mouse
    ];
  };
  # auto login and launch hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Replace <your_username> with your actual user
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
      initial_session = {
        command = "start-hyprland";
        user = "deathraymind";
      };
    };
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
