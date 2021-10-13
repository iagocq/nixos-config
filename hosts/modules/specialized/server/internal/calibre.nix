{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.calibre;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.calibre = {
    enable = mkEnableOption "Use a specialized configuration for an internal calibre server";
  };

  config = mkIf cfg.enable {
    srv.calibre = mkMerge [
      { enable = true; }
      ( removeAttrs int-cfg.calibre [ "secrets" ] )
    ];

    spc.int.secrets = int-cfg.calibre.secrets or [];
  };
}
