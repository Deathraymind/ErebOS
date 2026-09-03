{
  description = "NixOS Docker Host";
  inputs = {
    # Common
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # IshikoriOS
    flake-utils.url = "github:numtide/flake-utils";
    pelican.url = "github:Hythera/nix-pelican";
    sops-nix.url = "github:Mic92/sops-nix";
    #ErebOS
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # for cachy kernal
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
    };
    herdr.url = "github:ogulcancelik/herdr";
    niri.url = "github:sodiboo/niri-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs"; # keep it on your 26.05, don't pull a second nixpkgs
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    chaotic,
    noctalia,
    nixpkgs-unstable,
    nvf,
    ...
  } @ inputs: let
    hosts = import ./hosts/hosts.nix;
    # 1. Define the ROCm-specific unstable package here
    system = "x86_64-linux";
    unstable-pkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    # Specifically grab the ROCm-precompiled version
    ollama-unstable-rocm = unstable-pkgs.ollama-rocm;
  in {
    # =============================
    # DEPLOY-RS (2 nodes to start)
    # =============================
    deploy.nodes = {
      node1 = {
        hostname = "192.168.1.100"; # <-- the IP/name YOU ssh to for node1
        fastConnection = true;
        profiles.system = {
          sshUser = "deathraymind";
          interactiveSudo = true;
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.node1;
        };
      };

      cm220-1 = {
        hostname = "192.168.1.98"; # <-- the IP/name YOU ssh to for cm220-1
        fastConnection = true;
        profiles.system = {
          sshUser = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.cm220-1;
        };
      };
    };

    checks =
      builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      inputs.deploy-rs.lib;
    # =============================
    # PHYSICAL NODES
    # =============================
    #  nixosConfigurations.node-sylvath = nixpkgs.lib.nixosSystem {
    #system = "x86_64-linux";
    # modules = [
    #    ./hosts/nodes/node-sylvath/default.nix
    #  inputs.sops-nix.nixosModules.sops
    #];
    # specialArgs = {inherit inputs;};
    #};
    nixosConfigurations.node1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nodes/node1/default.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        inputs.sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.node1;
      };
    };
    nixosConfigurations.cm220-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nodes/cm220-1/default.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        inputs.sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.cm220-1;
      };
    };
    nixosConfigurations.cm220-2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nodes/cm220-2/default.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        inputs.sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.cm220-2;
      };
    };

    nixosConfigurations.node2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nodes/node2/default.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        inputs.sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.node2;
      };
    };
    # =============================
    # VM IMAGES (for building/importing)
    # =============================
    nixosConfigurations.caddy = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/vms/caddy/configuration.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        ./modules/vms/hardware-configuration.nix # Include our rewritten hardware file
        ./modules/common/common.nix # Include our rewritten hardware file

        inputs.sops-nix.nixosModules.sops
        # This block instructs Nix to build a generic VHD image layout
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.caddy;
      };
    };
    nixosConfigurations.coredns = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/containers/coredns/configuration.nix
        ./modules/common/networking.nix
        ./modules/containers/common.nix
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.coredns;
      };
    };
    nixosConfigurations.teleport = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/containers/teleport/configuration.nix
        ./modules/common/networking.nix
        ./modules/containers/common.nix
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.teleport;
      };
    };

    # nixosConfigurations.caddy-sylvath = nixpkgs.lib.nixosSystem {
    # system = "x86_64-linux";
    #  modules = [
    #./hosts/vms/caddy-sylvath/configuration.nix
    # ./modules/common/teleport.nix
    #  ./hosts/vms/caddy-sylvath/networking.nix
    # ./modules/vms/hardware-configuration.nix # Include our rewritten hardware file
    # ./modules/common/common.nix # Include our rewritten hardware file

    # inputs.sops-nix.nixosModules.sops
    # This block instructs Nix to build a generic VHD image layout
    # ];
    #      specialArgs = {inherit inputs;};
    #};

    nixosConfigurations.vaultwarden = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/vms/vaultwarden/configuration.nix
        ./modules/common/teleport.nix
        ./modules/common/networking.nix
        ./modules/vms/hardware-configuration.nix
        ./modules/common/common.nix

        inputs.sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.vaultwarden;
      };
    };
    nixosConfigurations.pelican = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.pelican.nixosModules.default
        {nixpkgs.overlays = [inputs.pelican.overlays.default];}
        ./hosts/vms/pelican/configuration.nix
        ./modules/common/networking.nix
        ./modules/common/teleport.nix
        ./modules/vms/hardware-configuration.nix # Include our rewritten hardware file
        ./modules/common/common.nix # Include our rewritten hardware file
        inputs.sops-nix.nixosModules.sops
        # Proxmox specific configuration (Replaced hardware-configuration.nix)
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.pelican;
      };
    };
    nixosConfigurations.pelican-wings = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.pelican.nixosModules.default
        {nixpkgs.overlays = [inputs.pelican.overlays.default];}
        ./modules/vms/hardware-configuration.nix
        ./modules/common/common.nix
        ./modules/common/teleport.nix
        ./hosts/vms/pelican-wings/configuration.nix
        ./modules/common/networking.nix
        inputs.sops-nix.nixosModules.sops
        # Proxmox specific configuration (Replaced hardware-configuration.nix)
      ];
      specialArgs = {
        inherit inputs;
        host = hosts.pelican-wings;
      };
    };
    # nixosConfigurations.pelican-sylvath-wings = nixpkgs.lib.#nixosSystem {
    #system = "x86_64-linux";
    #  modules = [
    # inputs.pelican.nixosModules.default
    #   {nixpkgs.overlays = [inputs.pelican.overlays.default];}
    #  ./modules/vms/hardware-configuration.nix
    #  ./modules/common/common.nix
    #  ./hosts/vms/pelican-sylvath-wings/configuration.nix
    #./hosts/vms/pelican-sylvath-wings/networking.nix
    # inputs.sops-nix.nixosModules.sops
    # Proxmox specific configuration (Replaced hardware-configuration.nix)
    #];
    #  specialArgs = {inherit inputs;};
    # };
    # =============================
    # WORKSTATIONS (ErebOS)
    # =============================
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        ollama-fix = ollama-unstable-rocm;
      };
      modules = [
        ./hosts/workstations/desktop/configuration.nix
        ./modules/erebos/system/default.nix
        ./modules/erebos/programs/defaultPrograms.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
        chaotic.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs;};
            users.deathraymind.imports = [./hosts/workstations/desktop/home.nix];
          };
        }
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        ollama-fix = ollama-unstable-rocm;
      };
      modules = [
        ./hosts/workstations/laptop/configuration.nix
        ./modules/erebos/system/default.nix
        ./modules/erebos/programs/defaultPrograms.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
        chaotic.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs;};
            users.deathraymind.imports = [./hosts/workstations/laptop/home.nix];
          };
        }
      ];
    };
  };
}
