{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    iago-nixpkgs.url = "github:iagocq/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zsh-f-sy-h.url = "github:zdharma/fast-syntax-highlighting";
    zsh-f-sy-h.flake = false;

    nnn-src.url = "github:jarun/nnn";
    nnn-src.flake = false;
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    overlays = system:
    let
      nixpkgs-config = { inherit system; config.allowUnfree = true; };
      iago-nixpkgs = import inputs.iago-nixpkgs nixpkgs-config;
    in
    [
      (final: prev: { zsh-f-sy-h = inputs.zsh-f-sy-h; })
      (final: prev: { nnn-src = inputs.nnn-src; })
      (final: prev: { adguardhome = iago-nixpkgs.adguardhome; })
    ];
    mkSystem = { host, system, extra-modules ? [], extra ? {}}: nixpkgs.lib.nixosSystem ({
      inherit system;
      modules = [
        (import ./hosts/common/overlay.nix (overlays system))
        (import (./hosts + "/${host}/configuration.nix"))
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.iago = import (./home/iago + "/home-${host}.nix");
          };
        }
      ] ++ extra-modules;
    } // extra);
  in
  {
    nixosConfigurations = {
      desktop-iago = mkSystem { host = "desktop-iago"; system = "x86_64-linux"; };
      raspberrypi  = mkSystem { host = "raspberrypi";  system = "aarch64-linux"; };

      # nix build .#nixosConfigurations.raspberrypi-sd-image.config.system.build.sdImage
      raspberrypi-sd-image = mkSystem rec {
        host = "raspberrypi";
        system = "aarch64-linux";
        extra-modules = [
          (import "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix" )
          ({ ... }: { sdImage.compressImage = false; })
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
