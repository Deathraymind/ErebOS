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
    ...
  } @ inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
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
            users.deathraymind.imports = [
              ./hosts/desktop/home.nix
            ];
          };
        }
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
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
            users.deathraymind.imports = [
              ./hosts/laptop/home.nix
            ];
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
