{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.dns;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.dns = {
    enable = mkEnableOption "Use a specialized configuration for an internal DNS server";

    bind = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };

    adguard = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.adguard.enable {
      srv.adguard = mkMerge [
        { enable = mkDefault true; }
        ( removeAttrs int-cfg.adguard [ "secrets" ] )
      ];

      spc.int.secrets = int-cfg.bind.secrets or [];
    })

    (mkIf cfg.bind.enable {
      srv.bind = mkMerge [
        { enable = mkDefault true; }
        ( removeAttrs int-cfg.bind [ "secrets" ] )
      ];

      spc.int.secrets = int-cfg.bind.secrets or [];
    })
  ]);
}
