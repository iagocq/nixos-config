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
  };

  outputs = ({ ... }@inputs:
    let
      config = import ./config;
      lib = import ./lib inputs;

      mkOverlays = { overlays ? [], ...}@args: inputs.overlays.mkOverlays ({
        inherit (config) nixpkgs;
        overlays = [ inputs.agenix.overlay ] ++ overlays;
      } // removeAttrs args [ "overlays" ]);

      mkSystem = { modules ? [], ... }@args: lib.mkSystem ({
        inherit (config) nixpkgs;
        inherit mkOverlays;
        users = [ "iago" ];
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
            (import "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix")
            {
              users.users.iago.initialHashedPassword = "";
              services.getty.autologinUser = lib.mkForce "iago";
              sdImage.compressImage = false;
            }
          ];
        };

        # nix build .#nixosConfigurations.wsl.config.system.build.tarball
        wsl = mkSystem {
          host = "wsl";
          system = "x86_64-linux";
          nixpkgs = {
            config.vim.gui = false;
          };
        };
      };
    }
  );
}
