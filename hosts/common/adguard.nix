{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.adguard;
in
{
  options.common.adguard = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    port = mkOption {
      type = types.port;
      default = 8333;
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };

  config = {
    services.adguardhome = mkIf cfg.enable {
      enable = true;
      port = cfg.port;
      host = cfg.address;
      extraArgs = [ "--no-etc-hosts" ];
    };
  };
}
