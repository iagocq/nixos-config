{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.common.lightspeed;
  s = config.common.secrets;
  format = pkgs.formats.json {};
in
{
  options.common.lightspeed = {
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
        default = "0.0.0.0";
      };
      
      webrtc-address = mkOption {
        type = types.str;
        default = s.lightspeed.address;
      };

      webrtc-ports = mkOption {
        type = types.attrsOf types.port;
        default = { from = 20000; to = 20500; };
      };

      ws-port = mkOption {
        type = types.port;
        default = 8080;
      };
    };

    open-firewall = mkOption {
      type = types.bool;
      default = true;
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
            wsUrl = "wss://${cfg.domain}/websocket";
          }).outPath + " =404";
        };

        "/websocket" = {
          proxyPass = "http://${cfg.webrtc.address}:${toString cfg.webrtc.ws-port}";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 1d;
          '';
        };
      };
    };

    networking.firewall = mkIf cfg.open-firewall {
      allowedUDPPortRanges = [ cfg.webrtc.webrtc-ports ];
      allowedUDPPorts = [ 65535 ];
    };
  };
}
