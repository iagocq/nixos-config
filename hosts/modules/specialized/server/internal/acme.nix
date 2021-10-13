{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.acme;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.acme = {
    enable = mkEnableOption "Use a specialized configuration for an internal ACME client";
  };

  config = mkIf cfg.enable {
    srv.acme = mkMerge [
      { enable = mkDefault true; }
      ( removeAttrs int-cfg.acme [ "secrets" ] )
    ];

    age.secrets."acme-credentials".file = ./acme-credentials.age;
    spc.int.secrets = int-cfg.acme.secrets or [];
  };
}
