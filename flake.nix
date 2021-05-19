{
  description = "Iago's NixOS system configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations = {

      nixos-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos-pc/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.iago = import ./home/iago/home.nix;
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
