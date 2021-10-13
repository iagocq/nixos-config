{ config, lib, pkgs, ... }@args:

with lib;
let
  secrets = config.age.secrets;
in
{
  imports = [
    ./config.nix
  ];

  options.spc.int.cfg = mkOption {
    type = types.attrsOf types.anything;
    default = {
      acme = {};
      adguard = {};
      bind = {};
      bitwarden = {};
      calibre = {};
      nginx = {};
    };
  };
}
