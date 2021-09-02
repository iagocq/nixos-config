{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.common.lightspeed;
  s = config.common.secrets;
  format = pkgs.formats.json {};
in
{
  options = {
    common.lightspeed = {
      enable = mkEnableOption "";

      domain = mkOption {
        type = types.str;
        default = "ls.${config.common.nginx.domain}";
      };

      vhost = mkOption {
        type = types.bool;
        default = true;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.lightspeed-react;
      };

      ingest = {
        stream-key = mkOption {
          type = types.str;
          default = s.lightspeed.stream-key;
        };

        ingest-address = mkOption {
          type = types.str;
          default = "0.0.0.0";
        };
      };

      webrtc = {
        address = mkOption {
          type = types.str;
          default = "localhost";
        };
        
        webrtc-address = mkOption {
          default = "127.0.0.1";
          type = types.str;
        };

        webrtc-ports = mkOption {
          default = "20000-20500";
          type = types.str;
        };

        ws-port = mkOption {
          default = 8080;
          type = types.port;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.lightspeed.ingest = {
      enable = true;
      streamKey = cfg.ingest.stream-key;
    };

    services.lightspeed.webrtc = {
      enable = true;
      address = cfg.webrtc.address;
      webrtcPorts = cfg.webrtc.webrtc-ports;
      webrtcAddress = cfg.webrtc.webrtc-address;
      wsPort = cfg.webrtc.ws-port;
    };

    common.nginx.vhosts.${cfg.domain} = mkIf cfg.vhost {
      locations = {
        "/" = {
          root = "${cfg.package}";
          tryFiles = "$uri $uri/ =404";
        };

        "/config.json" = {
          root = "/";
          tryFiles = (format.generate "config.json" {
            wsUrl = "ws://127.0.0.1/websocket";
          }).outPath + " =404";
        };

        "/websocket" = {
          proxyPass = "http://${cfg.webrtc.address}:${toString cfg.webrtc.ws-port}";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
    };
  };
}
