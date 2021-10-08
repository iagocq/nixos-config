
{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    overlays.url = "path:overlays";
    overlays.inputs.iago-nix.follows = "iago-nix";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    iago-nix.url = "github:iagocq/nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = ({ ... }@inputs:
    let
      config = import ./config;
      lib = import ./lib inputs;

      mkOverlays = { overlays ? [], ...}@args: inputs.overlays.mkOverlays ({
        inherit (config) nixpkgs;
        overlays = [ inputs.agenix.overlay ] ++ overlays;
      } // removeAttrs args [ "overlays" ]);

      mkSystem = { modules ? [], users ? [ "iago" ], ... }@args: lib.mkSystem ({
        inherit (config) nixpkgs;
        inherit mkOverlays users;
        modules = [
          inputs.agenix.nixosModules.age
        ] ++ lib.nlib.attrsets.attrValues inputs.iago-nix.nixosModules
          ++ modules;
      } // removeAttrs args [ "modules" ]);
    in
    {
      nixosConfigurations = {
        desktop-iago = mkSystem {
          host = "desktop-iago";
          system = "x86_64-linux";
          type = "desktop";
        };

        raspberrypi = mkSystem {
          host = "raspberrypi";
          system = "aarch64-linux";
          type = "embedded";
        };

        # nix build .#nixosConfigurations.raspberrypi-sd-image.config.system.build.sdImage
        raspberrypi-sd-image = mkSystem {
          host = "raspberrypi";
          system = "aarch64-linux";
          type = "embedded";
          modules = [
            (import "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix")
            {
              users.users.iago.initialHashedPassword = "";
              services.getty.autologinUser = lib.mkForce "iago";
              sdImage.compressImage = false;
            }
          ];
        };

        # nix build .#nixosConfigurations.desktop-iago-win.config.system.build.tarball
        desktop-iago-win = mkSystem {
          host = "desktop-iago-win";
          system = "x86_64-linux";
          type = "embedded";
          nixpkgs = {
            config.vim.gui = false;
          };
        };

        amogus = mkSystem {
          host = "amogus";
          system = "aarch64-linux";
          type = "server";
          nixpkgs = {
            config.vim.gui = false;
          };
        };

        # nix build .#nixosConfigurations.amogus-kexec.config.system.build.kexec_tarball
        amogus-kexec = mkSystem {
          host = "amogus";
          system = "aarch64-linux";
          type = "server";
          modules = [
            (import ./hosts/amogus-kexec/configuration.nix)
          ];
          nixpkgs = {
            config.vim.gui = false;
          };
        };

        lap-1 = mkSystem {
          users = [ "c" ];
          host = "lap-1";
          system = "x86_64-linux";
          type = "laptop";
        };
      };
    }
  );
}
