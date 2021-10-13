{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.nginx;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.nginx = {
    enable = mkEnableOption "use a specialized configuration for an internal server";
  };

  config = mkIf cfg.enable {
    srv.nginx = mkMerge [
      { enable = true; }
      ( removeAttrs int-cfg.nginx [ "secrets" ] )
    ];

    spc.int.secrets = int-cfg.nginx.secrets or [];
  };
}
