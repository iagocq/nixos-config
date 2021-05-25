{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    iago-nixpkgs.url = "github:iagocq/nixpkgs";

    # https://github.com/NixOS/nixpkgs/issues/124372
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
      nixpkgs-master = import inputs.nixpkgs-master nixpkgs-config;
      iago-nixpkgs = import inputs.iago-nixpkgs nixpkgs-config;
    in
    [
      (final: prev: { zsh-f-sy-h = inputs.zsh-f-sy-h; })
      (final: prev: { nnn-src = inputs.nnn-src; })
      (final: prev: { adguardhome = iago-nixpkgs.adguardhome; })
      # https://github.com/NixOS/nixpkgs/issues/124368
      # https://github.com/NixOS/nixpkgs/issues/104340#issuecomment-730815509
      (final: prev: { discord = prev.callPackage (prev.writeText "base.nix" (builtins.replaceStrings [ "\${libPath}" "Path [" ] [ "\${libPath}:$out/opt/\${binaryName}" "Path [ libdrm mesa"] (builtins.readFile "${inputs.nixpkgs}/pkgs/applications/networking/instant-messengers/discord/base.nix"))) rec {
        pname = "discord";
        binaryName = "Discord";
        desktopName = "Discord";
        version = "0.0.15";
        src = prev.fetchurl {
          url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = "0pn2qczim79hqk2limgh88fsn93sa8wvana74mpdk5n6x5afkvdd";
        };
      }; })
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
