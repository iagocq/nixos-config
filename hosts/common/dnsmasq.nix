{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.dnsmasq;
  s = config.common.secrets;
in
{
  options.common.dnsmasq = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
      default = s.network.intranet-domain;
    };

    dns-port = mkOption {
      type = types.port;
      default = 5553;
    };

    dhcp-range = mkOption {
      type = types.str;
      default = s.network.dhcp.range;
    };

    router = mkOption {
      type = types.str;
      default = s.network.gateway;
    };

    dns-server = mkOption {
      type = types.str;
      default = s.network.dns-server;
    };

    dhcp-subnet = mkOption {
      type = types.str;
      default = s.network.subnet;
    };

    extra-config = mkOption {
      type = types.lines;
      default = s.network.dhcp.dnsmasq-extra;
    };
  };

  config = {
    services.dnsmasq = mkIf cfg.enable {
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
  };
}
