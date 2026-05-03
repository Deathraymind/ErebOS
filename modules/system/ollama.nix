{
  pkgs,
  inputs,
  config,
  lib,
  ollama-fix,
  openclaw,
  ...
}: let
  # This tells Nix to use the unstable branch for this specific variable
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux"; # Standard for most PCs
    config.allowUnfree = true;
  };
in {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "open-webui"
    ];
  nixpkgs.config.allowUnfree = true;
  hardware.amdgpu.opencl.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  hardware.graphics = {
    enable = true;
  };

  services.open-webui = {
    enable = true;
    port = 8081;
    # This allows Open WebUI to talk to your Ollama service
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "tavily"; # or "google_pse"
      TAVILY_API_KEY = "YOUR_TAVILY_KEY_HERE";

      # Optional: Make the search more thorough
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      # This helps Gemma understand the search data better
      RAG_TEMPLATE = "Use the following search results to answer the query: [context]";
    };
  };

  services.ollama = {
    enable = true;
    package = ollama-fix;
    loadModels = ["codellama" "llama3.2"];
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.1";
  };
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "10.3.1";
    LD_LIBRARY_PATH = lib.mkForce "/run/opengl-driver/lib";

    # This tells ROCm to be extra vocal about why it might fail
    AMD_LOG_LEVEL = "3";
    ROCR_VISIBLE_DEVICES = "0";
  };
  environment.systemPackages = [ollama-fix];
  # Required for ROCm to work correctly on NixOS
}
