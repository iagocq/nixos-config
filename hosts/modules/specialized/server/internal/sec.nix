{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.secrets;

  age-secrets = (import ./age.nix { inherit lib pkgs; }).age;
in
{
  options.spc.int.secrets = mkOption {
    type = types.listOf types.str;
    default = [];
  };

  config = mkIf (cfg != []) {
    age.secrets = listToAttrs (map (x: { name = x; value = age-secrets.${x}; }) cfg);
  };
}
