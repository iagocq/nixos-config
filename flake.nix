{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    iago-nix.url = "github:iagocq/nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    nur.url = "github:nix-community/NUR";

    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = ({ ... }@inputs:
    let
      lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager; };

      flakeOverlays = cfg:
        with inputs; [
          iago-nix.overlay
          agenix.overlay
          nur.overlay
        ];

      flakeModules = with inputs; [
        agenix.nixosModules.age
        impermanence.nixosModules.impermanence
        iago-nix.nixosModules.lightspeed
        {
          nix.registry.nur.flake = inputs.nur;
          nix.nixPath = [ "nur=${inputs.nur}" ];
        }
      ];

      nixpkgsConfig = {
        config.allowUnfree = true;
      };

      mkOverlays = { nixpkgs, system, overlays ? [] }:
        flakeOverlays (nixpkgs // { inherit system; })
        ++ overlays;

      mkSystem = { modules ? [], users ? [ "iago" ], nixpkgs ? {}, ... }@args: lib.mkSystem (args // {
        inherit mkOverlays users;

        nixpkgs = lib.attrsets.recursiveUpdate nixpkgsConfig nixpkgs;
        modules = flakeModules ++ modules;
      });

      mkOlive = system: mkSystem {
        host = "olive";
        inherit system;
        modules = [{
          device.boot.mount = false;
          device.zfs.mount = false;
        }];
      };
    in
    {
      nixosConfigurations = {
        lasagna = mkSystem {
          host = "lasagna";
          system = "x86_64-linux";
        };

        pie = mkSystem {
          host = "pie";
          system = "aarch64-linux";
        };

        # nix build .#nixosConfigurations.pie-sd-image.config.system.build.sdImage
        pie-sd-image = mkSystem {
          host = "pie";
          system = "aarch64-linux";
          modules = [
            ({ modulesPath, ...}: import "${modulesPath}/installer/sd-card/sd-image-aarch64-installer.nix")
            {
              services.getty.autologinUser = lib.mkForce "iago";
              sdImage.compressImage = false;
            }
          ];
        };

        # nix build .#nixosConfigurations.moldy-lasagna.config.system.build.tarball
        moldy-lasagna = mkSystem {
          host = "desktop-iago-win";
          system = "x86_64-linux";
        };

        pineapple = mkSystem {
          host = "pineapple";
          system = "aarch64-linux";
        };

        olive-aarch64 = mkOlive "aarch64-linux";
        olive-x86_64 = mkOlive "x86_64-linux";

        lap-1 = mkSystem {
          users = [ "c" "iago" ];
          host = "lap-1";
          system = "x86_64-linux";
        };

        installer = mkSystem {
          host = "installer";
          system = "x86_64-linux";
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
              ];
            })
          ];
        };

        buffet = mkSystem {
          host = "buffet";
          system = "x86_64-linux";
        };
      };
    }
  );
}
