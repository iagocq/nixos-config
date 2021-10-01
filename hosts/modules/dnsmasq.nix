{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.dnsmasq;
  lan = config.common.info.network.lan;
in
{
  options.common.dnsmasq = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
      default = lan.lan-domain;
    };

    dns-port = mkOption {
      type = types.port;
      default = 5553;
    };

    dhcp-range = mkOption {
      type = types.str;
      default = lan.dhcp.range;
    };

    router = mkOption {
      type = types.str;
      default = lan.gateway;
    };

    dns-server = mkOption {
      type = types.str;
      default = lan.dns-server;
    };

    dhcp-subnet = mkOption {
      type = types.str;
      default = lan.subnet;
    };

    extra-config = mkOption {
      type = types.lines;
      default = lan.dhcp.dnsmasq-extra;
    };

    open-firewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      extraConfig = ''
        port=${toString cfg.dns-port}
        dhcp-range=${cfg.dhcp-range}
        dhcp-option=3,${cfg.router}
        dhcp-option=6,${cfg.dns-server}
        dhcp-authoritative
        dhcp-rapid-commit
        domain-needed
        bogus-priv
        no-resolv
        no-hosts
        domain=${cfg.domain},${cfg.dhcp-subnet},local
      '' + cfg.extra-config;
    };

    networking.firewall.allowedUDPPorts = mkIf cfg.open-firewall [ 67 ];
  };
}
