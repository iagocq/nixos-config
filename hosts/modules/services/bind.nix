{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.bind;
in
{
  options.srv.bind = {
    enable = mkEnableOption "Enable bind service";

    listenOn = mkOption {
      type = types.listOf types.str;
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
    };

    extraOptions = mkOption {
      type = types.str;
      default = "";
    };

    cacheNetworks = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.0/8" ];
    };

    forwarders = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    services.bind =  {
      enable = true;
      ipv4Only = true;
      inherit (cfg) listenOn forwarders extraConfig extraOptions cacheNetworks;
    };
  };
}
