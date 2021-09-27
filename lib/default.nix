{ ... }@inputs:

let
  nlib = inputs.nixpkgs.lib;
  mkSystem = {
      host
    , system
    , home-manager ? true
    , users ? []
    , modules ? []
    , nixpkgs ? {}
    , mkOverlays ? _: [], ... }@args: nlib.nixosSystem ({

    specialArgs = { inherit inputs users; };
    modules = [
      (../hosts + "/${host}/configuration.nix")
      {
        networking.hostName = nlib.mkDefault host;
        nix.registry.nixpkgs.flake = inputs.nixpkgs;

        nixpkgs = nlib.attrsets.recursiveUpdate {
          overlays = mkOverlays { inherit system; };
        } nixpkgs;
      }
    ] ++ modules
      ++ nlib.lists.optionals home-manager [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = nlib.foldr (user: next:
              let
                path = ../home + "/${user}";
                attrs = {
                  ${user} = import path;
                };
              in if (builtins.pathExists path) then attrs // next else next
            ) {} users;
            sharedModules = [ ../home/modules ];
            extraSpecialArgs = { inherit host; };
          };
        }
      ];
  } // removeAttrs args [ "host" "home-manager" "users" "modules" "nixpkgs" "mkOverlays" ]);
  wrap = f: default: args: f (default // args);
in
{
  inherit nlib mkSystem wrap;
}
