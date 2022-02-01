{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.nginx;
  mkVhost = vhost: {
    extraConfig = cfg.sslExtraConfig + vhost.extraConfig or "";
    listen = cfg.listen;
  } // cfg.ssl // removeAttrs vhost [ "extraConfig" ];
in
{
  options.srv.nginx = {
    enable = mkEnableOption "Enable nginx service";

    domain = mkOption {
      type = types.str;
    };

    ssl = mkOption {
      type = types.attrsOf types.anything;
      default = {
        useACMEHost = cfg.domain;
        forceSSL = true;
      };
    };

    httpPort = mkOption {
      type = types.port;
      default = 80;
    };

    httpsPort = mkOption {
      type = types.port;
      default = 443;
    };

    listen = mkOption {
      type = types.listOf (types.submodule {
        options = {
          addr = mkOption {
            type = types.str;
          };

          port = mkOption {
            type = types.port;
          };

          ssl = mkOption {
            type = types.bool;
            default = false;
          };
        };
      });

      default = [
        { addr = "0.0.0.0"; port = cfg.httpsPort; ssl = true; }
        { addr = "0.0.0.0"; port = cfg.httpPort; }
        { addr = "[::]"; port = cfg.httpsPort; ssl = true; }
        { addr = "[::]"; port = cfg.httpPort; }
      ];
    };

    resolverAddress = mkOption {
      type = types.listOf types.str;
    };

    dynamicResolving = mkOption {
      type = types.bool;
      default = false;
    };

    sslExtraConfig = mkOption {
      type = types.str;
      default = ''
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options DENY always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-XSS-Protection "1; mode=block" always;
      '';
    };

    vhosts = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };

    extraConfig = mkOption {
      type = type.str;
      default = "";
    };

    group = mkOption {
      type = types.str;
      default = "acme";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      group = cfg.group;

      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      resolver.addresses = mkIf cfg.dynamicResolving cfg.resolverAddresses;
      proxyResolveWhileRunning = mkDefault cfg.dynamicResolving;

      virtualHosts = mapAttrs (n: v: mkVhost v) cfg.vhosts;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall (map (x: x.port) cfg.listen);
  };
}
