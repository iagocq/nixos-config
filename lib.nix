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
  , hostsPath ? ./.
  , modules ? []
  , nixpkgs ? {}
  , overlays ? []
  , mkOverlays ? _: [], ... }@args: (lib.makeOverridable lib.nixosSystem) (
    let
      specialArgs = {
        inherit
          host globalConfig type home-manager users
          hostsPath modules nixpkgs overlays mkOverlays;
        isHomeManager = false;
      };
    in {
      inherit specialArgs;
      modules = modules ++ [
        "${hostsPath}/device"
        "${hostsPath}/services"
        "${hostsPath}/specialized"
        "${hostsPath}/users"
        "${hostsPath}/${host}/configuration.nix"
        ({ options, ...}: {
          networking.hostName = host;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;

          nixpkgs = lib.attrsets.recursiveUpdate {
            overlays = mkOverlays { inherit nixpkgs system overlays; };
          } args.nixpkgs;

          customUsers =
            let
              optUsers = builtins.attrNames (removeAttrs options.customUsers [ "extra" ]);
              cfgUsers = builtins.filter (x: builtins.elem x optUsers) users;
              extra = builtins.filter (x: !(builtins.elem x optUsers)) users;
            in
              lib.mkIf (users != []) (
                lib.mkMerge (
                  (map (x: { ${x}.enable = true; }) cfgUsers) ++ [ { extra = extra; } ]
                )
              );
        })
      ] ++ lib.lists.optionals home-manager [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              "${hostsPath}/device"
              "${hostsPath}/hm-modules"
              "${hostsPath}/${host}/device.nix"
            ];
            extraSpecialArgs = specialArgs // { isHomeManager = true; };
          };
        }
      ];
    } // removeAttrs args (builtins.attrNames specialArgs));
in
lib // {
  inherit mkSystem;
}
