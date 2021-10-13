{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.local.dnsmasq;
in
{
  options.srv.local.dnsmasq = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
    };

    dnsPort = mkOption {
      type = types.port;
      default = 5553;
    };

    dhcpRange = mkOption {
      type = types.str;
    };

    router = mkOption {
      type = types.str;
    };

    dnsServer = mkOption {
      type = types.str;
    };

    dhcpSubnet = mkOption {
      type = types.str;
    };

    extraConfig = mkOption {
      type = types.lines;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      extraConfig = ''
        port=${toString cfg.dnsPort}
        dhcp-range=${cfg.dhcpRange}
        dhcp-option=3,${cfg.router}
        dhcp-option=6,${cfg.dnsServer}
        dhcp-authoritative
        dhcp-rapid-commit
        domain-needed
        bogus-priv
        no-resolv
        no-hosts
        domain=${cfg.domain},${cfg.dhcpSubnet},local
      '' + cfg.extraConfig;
    };

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 67 ];
  };
}
