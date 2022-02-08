{ config, lib, options, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.network;
in
{
  options.spc.int.network = with types; {
    domain = mkOption { type = str; };
    lanSubdomain = mkOption { type = str; };
    lanDomain = mkOption { type = str; };
    net = mkOption { type = str; };
    netmask = mkOption { type = str; };
    subnet = mkOption { type = str; };
    broadcast = mkOption { type = str; };
    dnsServer = mkOption { type = str; };
    gateway = mkOption { type = str; };
    defaultRoute = mkOption { type = submodule ({ ... }: {
      options = {
        address = mkOption { type = str; };
        prefixLength = mkOption { type = int; };
        via = mkOption { type = str; };
      };
    }); };
    server = mkOption { type = submodule ({ ... }: {
      options = {
        host = mkOption { type = str; };
        mainAddress = mkOption { type = str; };
        addresses = mkOption { type = listOf anything; };
        extraHosts = mkOption { type = lines; };
      };
    }); };
  };

  config.spc.int.network = {
    domain = "iago.casa";
    lanSubdomain = "intra";
    lanDomain = "${cfg.lanSubdomain}.${cfg.domain}";
    net = "10.36.21.";
    netmask = "255.255.255.0";
    subnet = "${cfg.net}0/24";
    broadcast = "${cfg.net}255";
    dnsServer = "${cfg.net}11";
    gateway = "${cfg.net}1";
    defaultRoute = {
      address = "0.0.0.0";
      prefixLength = 0;
      via = cfg.gateway;
    };
    server = {
      host = "pie";
      mainAddress = "${cfg.net}10";
      addresses = [
        { address = "${cfg.net}10"; prefixLength = 24; }
        { address = "${cfg.net}11"; prefixLength = 24; }
      ];
      extraHosts = "";
    };
  };
}
