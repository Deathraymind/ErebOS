{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # This tells Nix to use the unstable branch for this specific variable
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux"; # Standard for most PCs
    config.allowUnfree = true;
  };
in {
  # ... your existing config ...{
  imports = [
    ./hardware-configuration.nix
  ];
  environment.systemPackages = [
    # This pulls the exact 'AxiomOS' package you were running
    # and installs it as 'nvim' on your system path.
    inputs.nvf-custom.packages.${pkgs.system}.default
    pkgs.hyprpaper
    pkgs.hyprshot
  ];
  services.udisks2.enable = true;
  # for ollama
  hardware.amdgpu.opencl.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  systemd.services.NetworkManager-wait-online.enable = false;
  services.ollama = {
    package = unstable.ollama;
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      # Add the full library path including the ROCm CLR and Drivers
      LD_LIBRARY_PATH = "/run/opengl-driver/lib:${pkgs.rocmPackages.clr}/lib:${pkgs.rocmPackages.clr.icd}/lib";
    };
  };

  # Make sure these are also explicitly in your system-wide extraPackages
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.clr.icd
    amdvlk # Sometimes helps the runner detect the card via Vulkan first
  ];

  # Critical: Give the 'ollama' user permission to use the GPU hardware
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    extraGroups = ["video" "render"];
  };
  users.groups.ollama = {};

  # Required for ROCm to work correctly on NixOS
  hardware.graphics.extraPackages = [
    pkgs.rocmPackages.clr.icd
    pkgs.rocmPackages.clr # Added this to provide the libraries
  ];

  # Kill that xrdb error once and for all
  # We still enable the module so Nix knows how to handle the manual/docs
  # but we don't need to define 'settings' if you just want the fork's defaults.

  # IMPORTANT: Stylix usually kills custom Neovim themes.
  # Disable it so your fork's Catppuccin theme actually shows up.

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = ["gnome" "gtk"];
        # Explicitly use gnome for screen sharing
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      };
    };
  };
  systemd.user.extraConfig = ''
    DefaultEnvironment="XDG_CURRENT_DESKTOP=niri"
  '';
  services.dbus.enable = true;
  environment.variables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
  };

  boot.loader = {
    grub = {
      enable = lib.mkForce true;
      efiSupport = true;
      devices = ["nodev"];
      configurationName = "BowOS";
      fontSize = 26;
      useOSProber = true;
    };
    efi = {
      canTouchEfiVariables = true;
      # Optional: specify EFI mount point if non-standard
      efiSysMountPoint = "/boot";
    };
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  boot.loader.systemd-boot.enable = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Use the systemd-boot EFI boot loader.

  networking.hostName = "AxiomOS";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  programs.zsh.enable = true;
  users.mutableUsers = false;
  users.users.deathraymind = {
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$Yu6LVySFa46PsKBHC7lkI.$fCdSJMULL1L2uOMhiY1WlR5QzW84qP42ktl2CxvSkgC";
    isNormalUser = true;
    extraGroups = ["dialout" "networkmanager" "wheel" "libvirtd" "vboxusers" "disk" "kvm" "video" "render" "docker" "adbusers" "ydotool" "uinput"];

    packages = with pkgs; [
    ];
  };

  ## Home Manager Import ##
  axiomos.steam.enable = true;
  axiomos.stylix = {
    enable = true;
    theme = "oxocarbon-dark";
  };

  services.openssh.enable = true;
  axiomos.cachy.enable = true;
  axiomos.autologin.enable = true;

  hardware.bluetooth.enable = true;
  services.upower.enable = true; # Needed for battery status

  system.stateVersion = "25.05";
}
