{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";

    iago-nix.url = "github:iagocq/nix";
    iago-nixpkgs.url = "github:iagocq/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zsh-f-sy-h.url = "github:zdharma/fast-syntax-highlighting";
    zsh-f-sy-h.flake = false;

    nnn-src.url = "github:jarun/nnn";
    nnn-src.flake = false;
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    lib = nixpkgs.lib;

    nixpkgs-config = { config.allowUnfree = true; };

    overlays = system:
    let
      iago-nixpkgs = import inputs.iago-nixpkgs ({ inherit system; } // nixpkgs-config);
    in
    [
      (final: prev: {
        zsh-f-sy-h = inputs.zsh-f-sy-h;
        nnn-src = inputs.nnn-src;
        adguardhome = iago-nixpkgs.adguardhome;
      })
      inputs.iago-nix.overlay
      inputs.agenix.overlay
    ];

    mkSystem = { host, system, modules ? [], nixpkgs ? {}, ... }@args: lib.nixosSystem ({
      modules = [
        #(./cachix)
        (./hosts + "/${host}/configuration.nix")
        inputs.agenix.nixosModules.age
        home-manager.nixosModules.home-manager
        {
          networking.hostName = host;

          nixpkgs = lib.attrsets.recursiveUpdate ({
            overlays = overlays system;
          } // nixpkgs-config) nixpkgs;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.iago = import (./home/iago + "/${host}/home.nix");
          };
        }
      ] ++ lib.attrsets.attrValues inputs.iago-nix.nixosModules
        ++ modules;
    } // (removeAttrs args [ "host" "modules" "nixpkgs" ]));
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
          (import "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix")
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
  };
}
