{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zsh-f-sy-h.url = "github:zdharma/fast-syntax-highlighting";
    zsh-f-sy-h.flake = false;
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    overlays = [
      (final: prev: { zsh-f-sy-h = inputs.zsh-f-sy-h; })
    ];
  in
  {
    nixosConfigurations = {

      nixos-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./hosts/common/overlay.nix overlays) 
          ./hosts/nixos-pc/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.iago = import ./home/iago/home-pc.nix;
            };
          }
        ];
      };

      nixos-rpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ ./hosts/nixos-rpi/configuration.nix ];
      };
    };
  };
}
