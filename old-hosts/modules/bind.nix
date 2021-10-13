{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.bind;
  info = config.common.info;
  bind = info.bind;
  lan = info.network.lan;
in
{
  options.common.bind = {
    enable = mkEnableOption "Enable bind9 service";

    listen-on = mkOption {
      type = types.listOf types.str;
      default = [ lan.bind ];
    };

    extra-config = mkOption {
      type = types.lines;
      default = bind.extra-config;
    };

    extra-options = mkOption {
      type = types.lines;
      default = bind.extra-options;
    };

    cache-networks = mkOption {
      default = [ "127.0.0.0/8" lan.subnet ];
    };

    forwarders = mkOption {
      default = [ lan.dns-server ];
    };
  };
 
  config = mkIf cfg.enable {
    services.bind = {
      enable = true;
      listenOn = cfg.listen-on;
      forwarders = cfg.forwarders;
      extraConfig = cfg.extra-config;
      extraOptions = cfg.extra-options;
      cacheNetworks = cfg.cache-networks;
    };
  };
}
