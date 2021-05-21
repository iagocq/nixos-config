{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.bitwarden_rs;
in
{
  options.common.bitwarden_rs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    config = mkOption {
      type = types.anything;
      default = {
        websocketEnabled = true;
        websocketAddress = "127.0.0.1";
        websocketPort = 3012;
        signupsAllowed = false;
        domain = cfg.domain;
        rocketAddress = "127.0.0.1";
        rocketPort = 8222;
      };
    };

    domain = mkOption {
      type = types.str;
      default = "https://${config.common.nginx.bitwarden.domain}";
    };
  };

  config = {
    services.bitwarden_rs = mkIf cfg.enable {
      enable = true;
      config = cfg.config;
    };
  };
}
