{
  pkgs,
  inputs,
  config,
  ...
}: {
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
}
