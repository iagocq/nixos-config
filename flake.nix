{
  description = "Iago's NixOS system configuration flake";

  inputs = {
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
    nixpkgs-config = { config.allowUnfree = true; config.vim.gui = false; };

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
    ];

    mkSystem = { host, system, ... }@args: nixpkgs.lib.nixosSystem ({
      modules = [
        (import (./hosts + "/${host}/configuration.nix"))
        { nixpkgs = { overlays = overlays system; } // nixpkgs-config; }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.iago = import (./home/iago + "/home-${host}.nix");
          };
        }
      ] ++ nixpkgs.lib.attrsets.attrValues inputs.iago-nix.nixosModules
        ++ (if (args ? modules) then args.modules else []);
    } // (removeAttrs args [ "modules" "host" ]));
  in
  {
    nixosConfigurations = {
      desktop-iago = mkSystem { host = "desktop-iago"; system = "x86_64-linux"; };
      raspberrypi  = mkSystem { host = "raspberrypi";  system = "aarch64-linux"; };

      # nix build .#nixosConfigurations.wsl.config.system.build.tarball
      wsl          = mkSystem { host = "wsl";          system = "x86_64-linux"; };

      # nix build .#nixosConfigurations.raspberrypi-sd-image.config.system.build.sdImage
      raspberrypi-sd-image = mkSystem {
        host = "raspberrypi";
        system = "aarch64-linux";
        modules = [
          (import "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix")
          { sdImage.compressImage = false; }
        ];
      };
    };

    homeConfigurations = {
      "iago@raspberrypi" = home-manager.lib.homeManagerConfiguration rec {
        system = "aarch64-linux";
        username = "iago";
        configuration = ./home/iago/home-rpi.nix;
        homeDirectory = "/home/iago";
        pkgs = import nixpkgs {
          overlays = overlays system;
          config.allowUnfree = true;
          system = system;
        };
      };
    };
  };
}
