{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.bitwarden;
  nginx = config.srv.nginx;
in
{
  options.spc.int.bitwarden = {
    enable = mkEnableOption "Use a specialized configuration for an internal Bitwarden server";
  };

  config = mkIf cfg.enable {
    srv.bitwarden = rec {
      enable = true;
      domain = nginx.domain;
      baseUri = "/bitwarden/";
      config = {
        websocketEnable = true;
        websocketAddress = "127.0.0.1";
        websocketPort = 8091;
        signupsAllowed = false;
        domain = "https://${nginx.domain}${baseUri}";
        rocketAddress = "127.0.0.1";
        rocketPort = 8090;
      };
    };
  };
}
