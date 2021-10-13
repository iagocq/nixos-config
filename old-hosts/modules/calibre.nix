{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.common.calibre;
  nginx = config.common.nginx;
in
{
  options.common.calibre = {
    enable = mkEnableOption "";

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    uploading = mkOption {
      type = types.bool;
      default = true;
    };

    domain = mkOption {
      type = types.str;
      default = nginx.domain;
    };

    base-uri = mkOption {
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

    common.nginx.vhosts.${cfg.domain} = mkIf cfg.vhost {
      locations = {
        "${cfg.base-uri}" = {
          proxyPass = "http://${cfg.address}:${toString cfg.port}";
          extraConfig = ''
            proxy_set_header X-Script-Name ${cfg.base-uri};
            proxy_set_header X-Scheme $scheme;
          '';
        };
      };
    };
  };
}
