{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.bind;
  s = config.common.secrets;
in
{
  options.common.bind = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    zones = mkOption {
      type = types.listOf types.anything;
      default = s.bind.zones;
    };

    listen-on = mkOption {
      type = types.listOf types.str;
      default = [ s.network.bind ];
    };

    extra-config = mkOption {
      type = types.lines;
      default = s.bind.extra-config;
    };

    extra-options = mkOption {
      type = types.lines;
      default = s.bind.extra-options;
    };

    cache-networks = mkOption {
      default = [ "127.0.0.0/8" s.network.subnet ];
    };

    forwarders = mkOption {
      default = [ s.network.dns-server ];
    };
  };
  
  config = {
    services.bind = mkIf cfg.enable {
      enable = true;
      zones = cfg.zones;
      listenOn = cfg.listen-on;
      forwarders = cfg.forwarders;
      extraConfig = cfg.extra-config;
      extraOptions = cfg.extra-options;
      cacheNetworks = cfg.cache-networks;
    };
  };
}
