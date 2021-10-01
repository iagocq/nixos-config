{ ... }@inputs:

let
  lib = inputs.nixpkgs.lib;
  mkSystem = {
    host
  , system
  , global-config ? {}
  , type ? "unknown"
  , home-manager ? true
  , users ? []
  , users-path ? ../users
  , modules ? []
  , nixpkgs ? {}
  , mkOverlays ? _: [], ... }@args: lib.nixosSystem (
  let specialArgs = { inherit host global-config type users users-path; }; in {

    inherit specialArgs;
    modules = [
      (../hosts + "/${host}/configuration.nix")
      {
        networking.hostName = lib.mkDefault host;
        nix.registry.nixpkgs.flake = inputs.nixpkgs;

        nixpkgs = lib.attrsets.recursiveUpdate {
          overlays = mkOverlays { inherit system; };
        } nixpkgs;
      }
    ] ++ modules
      ++ lib.lists.optionals home-manager [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users =
              let
                all-users = import users-path { inherit lib; pkgs = null; };
                ulib = all-users.lib;
              in ulib.attrsOf "hm-module" (ulib.loadUsers all-users users);

            sharedModules = [ (users-path + /hm-modules) ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
  } // removeAttrs args [ "host" "type" "home-manager" "users" "users-path" "modules" "nixpkgs" "mkOverlays" ]);
in
{
  nlib = lib;
  inherit mkSystem;
}
