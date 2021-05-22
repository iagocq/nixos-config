{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zsh-f-sy-h.url = "github:zdharma/fast-syntax-highlighting";
    zsh-f-sy-h.flake = false;

    nnn-src.url = "github:jarun/nnn";
    nnn-src.flake = false;
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    overlays = [
      (final: prev: { zsh-f-sy-h = inputs.zsh-f-sy-h; })
      (final: prev: { nnn-src = inputs.nnn-src; })
    ];
    mkSystem = { host, arch, extra-modules ? [], extra ? {}}: nixpkgs.lib.nixosSystem ({
      system = arch;
      modules = [
        (import ./hosts/common/overlay.nix overlays)
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

      desktop-iago = mkSystem { host = "desktop-iago"; arch = "x86_64-linux"; };
      raspberrypi  = mkSystem { host = "raspberrypi";  arch = "aarch64-linux"; };

      # nix build .#nixosConfigurations.nixos-rpi-sd-image.config.system.build.sdImage
      nixos-rpi-sd-image = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ (import ./hosts/nixos-rpi/configuration.sdImage.nix nixpkgs) ];
      };
    };

    homeConfigurations = {
      "iago@raspberrypi" = home-manager.lib.homeManagerConfiguration {
        system = "aarch64-linux";
        username = "iago";
        configuration = ./home/iago/home-rpi.nix;
        homeDirectory = "/home/iago";
        pkgs = import nixpkgs {
          inherit overlays;
          config.allowUnfree = true;
          system = "aarch64-linux";
        };
      };
    };
  };
}
