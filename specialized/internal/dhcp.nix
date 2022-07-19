{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.dhcp;
in
{
  options.spc.int.dhcp = {
    enable = mkEnableOption "Use a specialized configuration for an internal DHCP server";
  };

  config = mkIf cfg.enable {
    srv.local.dnsmasq =
      let
        network = config.spc.int.network;
        start = "${network.net}30";
        end = "${network.net}99";
      in
      {
        enable = true;
        domain = network.lanDomain;
        dhcpRange = "${start},${end},${network.netmask},${network.broadcast}";
        dhcpSubnet = network.subnet;
        router = network.gateway;
        dnsServer = network.dnsServer;
        extraConfig = "";
        #extraConfig = let host = config.networking.hostName; in ''
        #  host-record=${host}.${network.lanDomain},${host},${network.server.mainAddress}
        #'';
      };
  };
}
