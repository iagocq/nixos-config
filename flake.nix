
{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    tribler-nixpkgs.url = "github:viric/nixpkgs/tribler-master2";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    iago-nix.url = "github:iagocq/nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = ({ ... }@inputs:
    let
      lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager; };

      flakeOverlays = cfg:
        let
          tribler-nixpkgs = import inputs.tribler-nixpkgs cfg;
        in
        [
          (final: prev: {
            tribler = tribler-nixpkgs.pkgs.tribler;
          })
          inputs.iago-nix.overlay
          inputs.agenix.overlay
        ];

      flakeModules = with inputs; [
        agenix.nixosModules.age
        impermanence.nixosModules.impermanence
        iago-nix.nixosModules.lightspeed
        { nix.nixPath = [ "nixpkgs=${nixpkgs}" ]; }
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
    in
    {
      nixosConfigurations = {
        desktop-iago = mkSystem {
          host = "desktop-iago";
          system = "x86_64-linux";
        };

        raspberrypi = mkSystem {
          host = "raspberrypi";
          system = "aarch64-linux";
        };

        # nix build .#nixosConfigurations.raspberrypi-sd-image.config.system.build.sdImage
        raspberrypi-sd-image = mkSystem {
          host = "raspberrypi";
          system = "aarch64-linux";
          modules = [
            ({ modulesPath, ...}: import "${modulesPath}/installer/sd-card/sd-image-aarch64-installer.nix")
            {
              services.getty.autologinUser = lib.mkForce "iago";
              sdImage.compressImage = false;
            }
          ];
        };

        # nix build .#nixosConfigurations.desktop-iago-win.config.system.build.tarball
        desktop-iago-win = mkSystem {
          host = "desktop-iago-win";
          system = "x86_64-linux";
        };

        amogus = mkSystem {
          host = "amogus";
          system = "aarch64-linux";
        };

        amogus-nomount = mkSystem {
          host = "amogus";
          system = "aarch64-linux";
          modules = [
            {
              device.uefi.mount = false;
              device.zfs.mount = false;
            }
          ];
        };

        lap-1 = mkSystem {
          users = [ "c" "iago" ];
          host = "lap-1";
          system = "x86_64-linux";
        };

        installer = mkSystem {
          host = "installer";
          system = "x86_64-linux";
        };
      };
    }
  );
}
