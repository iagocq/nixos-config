{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.bitwarden;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.bitwarden = {
    enable = mkEnableOption "Use a specialized configuration for an internal Bitwarden server";
  };

  config = mkIf cfg.enable {
    srv.bitwarden = mkMerge [
      { enable = true; }
      ( removeAttrs int-cfg.bitwarden [ "secrets" ] )
    ];

    spc.int.secrets = int-cfg.bitwarden.secrets or [];
  };
}
