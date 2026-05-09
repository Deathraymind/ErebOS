{
  description = "A very basic flake";
  # this is ErbOS
  inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Official Plugins Flake - forced to follow your Hyprland version
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # for cachy kernal
    openclaw.url = "github:openclaw/nix-openclaw";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    stylix.url = "github:danth/stylix";
    nvf-custom.url = "github:deathraymind/nvf";
    hyprland.url = "github:hyprwm/Hyprland/";
    niri.url = "github:sodiboo/niri-flake";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # This is the magic line
    };

    # Add Hyprspace here pinned to the working commit
    hyprspace = {
      url = "github:KZDKM/Hyprspace"; # Pinned to the 0.53 compat commit
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    chaotic,
    noctalia,
    nixpkgs-unstable,
    openclaw,
    ...
  } @ inputs: let
    # 1. Define the ROCm-specific unstable package here
    system = "x86_64-linux";
    unstable-pkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    # Specifically grab the ROCm-precompiled version
    ollama-unstable-rocm = unstable-pkgs.ollama-rocm;
  in {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      # 2. Add 'ollama-unstable-rocm' to specialArgs so configuration.nix can use it
      specialArgs = {
        inherit inputs;
        ollama-fix = ollama-unstable-rocm;
      };
      modules = [
        ./hosts/desktop/configuration.nix
        ./modules/system/default.nix
        ./modules/programs/defaultPrograms.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
        chaotic.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs;};
            users.deathraymind.imports = [./hosts/desktop/home.nix];
          };
        }
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      # 2. Add 'ollama-unstable-rocm' to specialArgs so configuration.nix can use it
      specialArgs = {
        inherit inputs;
        ollama-fix = ollama-unstable-rocm;
      };
      modules = [
        ./hosts/laptop/configuration.nix
        ./modules/system/default.nix
        ./modules/programs/defaultPrograms.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
        chaotic.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs;};
            users.deathraymind.imports = [./hosts/laptop/home.nix];
          };
        }
      ];
    };

    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/vm/configuration.nix
        ./modules/system/default.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs;};
            users.deathraymind = import ./hosts/vm/home.nix;
          };
        }
      ];
    };
  };
}
