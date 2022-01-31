{ nixpkgs, home-manager }@inputs:

let
  lib = inputs.nixpkgs.lib;
  mkSystem = {
    host
  , system
  , globalConfig ? {}
  , type ? "unknown"
  , home-manager ? true
  , users ? []
  , hostsPath ? ./hosts
  , usersPath ? "${hostsPath}/users"
  , modules ? []
  , nixpkgs ? {}
  , overlays ? []
  , mkOverlays ? _: [], ... }@args: (lib.makeOverridable lib.nixosSystem) (
    let
      specialArgs = { inherit host globalConfig type home-manager users hostsPath usersPath modules nixpkgs overlays mkOverlays; };
    in {
      inherit specialArgs;
      modules = modules ++ [
        "${hostsPath}/modules"
        "${hostsPath}/${host}/configuration.nix"
        {
          networking.hostName = host;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;

          nixpkgs = lib.attrsets.recursiveUpdate {
            overlays = mkOverlays { inherit nixpkgs system overlays; };
          } args.nixpkgs;
        }
      ] ++ lib.lists.optionals home-manager [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users =
              let
                allUsers = import usersPath { inherit lib; };
                ulib = allUsers.lib;
              in ulib.attrsOf "hm-module" (ulib.loadUsers allUsers users);

            sharedModules = [ "${usersPath}/hm-modules" ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    } // removeAttrs args (builtins.attrNames specialArgs));
in
lib // {
  inherit mkSystem;
}
