
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
      lib = import ./lib inputs;

      mkOverlays = { nixpkgs, system, overlays ? [] }:
        let
          cfg-final = nixpkgs // { inherit system; };
          tribler-npkgs = import inputs.tribler-nixpkgs cfg-final;
        in
        [
          (final: prev: {
            tribler = tribler-npkgs.pkgs.tribler;
          })
          inputs.iago-nix.overlay
          inputs.agenix.overlay
        ] ++ overlays;

      mkSystem = { modules ? [], users ? [ "iago" ], ... }@args: lib.mkSystem ({
        inherit mkOverlays users;

        nixpkgs = lib.nlib.attrsets.recursiveUpdate {
          config.allowUnfree = true;
        } args.nixpkgs or {};

        modules = [
          inputs.agenix.nixosModules.age
          inputs.impermanence.nixosModules.impermanence
        ] ++ lib.nlib.attrsets.attrValues inputs.iago-nix.nixosModules
          ++ modules;
      } // removeAttrs args [ "modules" ]);
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
