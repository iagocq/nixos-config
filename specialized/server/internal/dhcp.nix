{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.dhcp;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.dhcp = {
    enable = mkEnableOption "Use a specialized configuration for an internal DHCP server";
  };

  config = mkIf cfg.enable {
    srv.local.dnsmasq = mkMerge [
      { enable = mkDefault true; }
      ( removeAttrs int-cfg.dnsmasq [ "secrets" ] )
    ];

    spc.int.secrets = int-cfg.dnsmasq.secrets or [];
  };
}
