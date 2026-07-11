{
  description = "A very basic flake";
  # this is ErbOS
  inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # for cachy kernal
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    stylix.url = "github:danth/stylix";
    nvf-custom.url = "github:deathraymind/nvf";
    niri.url = "github:sodiboo/niri-flake";

    # Add Hyprspace here pinned to the working commit
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
  };
}
