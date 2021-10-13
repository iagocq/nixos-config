{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.calibre;
  nginx = config.srv.nginx;
in
{
  options.srv.calibre = {
    enable = mkEnableOption "Enable calibre service";

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 8444;
    };

    uploading = mkOption {
      type = types.bool;
      default = true;
    };

    domain = mkOption {
      type = types.str;
      default  = nginx.domain;
    };

    baseUri = mkOption {
      type = types.str;
      default = "/calibre";
    };

    vhost = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      listen.ip = cfg.address;
      listen.port = cfg.port;
      options = {
        enableBookConversion = true;
        enableBookUploading = cfg.uploading;
      };
    };
  };
}
