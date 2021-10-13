{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.sslh;
  mkServiceOptions = enable: port: {
    enable = mkOption {
      type = types.bool;
      default = enable;
    };

    port = mkOption {
      type = types.port;
      default = port;
    };
  };
  optionalString = strings.optionalString;
  nginx-addresses = (if cfg.enable && cfg.tls.enable && cfg.port == 443 then [
    { addr = "127.0.0.1"; port = 8443; ssl = true; }
    { addr = "[::1]"; port = 8443; ssl = true; }
  ] else [
    { addr = "0.0.0.0"; port = 443; ssl = true; }
    { addr = "[::]"; port = 443; ssl = true; }
  ]) ++ [
    { addr = "0.0.0.0"; port = 80; }
    { addr = "[::]"; port = 80; }
  ];
in
{
  options.common.sslh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    port = mkOption {
      type = types.port;
      default = 443;
    };

    transparent = mkOption {
      type = types.bool;
      default = true;
    };

    ssh = mkServiceOptions true 22;
    openvpn = mkServiceOptions true 1194;
    http = mkServiceOptions false 80;
    tls = mkServiceOptions true 8443;
    any = mkServiceOptions false 0;
  };

  config = {
    services.sslh = mkIf cfg.enable {
      enable = true;
      transparent = cfg.transparent;
      port = cfg.port;
      timeout = 5;
      appendConfig = ''
        protocols: (
          ${optionalString cfg.ssh.enable     ''{ name: "ssh"; service: "ssh"; host: "localhost"; port: "${toString cfg.ssh.port}"; probe: "builtin"; },''}
          ${optionalString cfg.openvpn.enable ''{ name: "openvpn"; host: "localhost"; port: "${toString cfg.openvpn.port}"; probe: "builtin"; },''}
          ${optionalString cfg.http.enable    ''{ name: "http"; host: "localhost"; port: "${toString cfg.http.port}"; probe: "builtin"; },''}
          ${optionalString cfg.tls.enable     ''{ name: "tls"; host: "localhost"; port: "${toString cfg.tls.port}"; probe: "builtin"; },''}
          ${optionalString cfg.any.enable     ''{ name: "anyprot"; host: "localhost"; port: "${toString cfg.any.port}"; probe: "builtin"; },''}
        );
      '';
    };

    common.nginx.listen-on = mkIf cfg.enable (mkDefault nginx-addresses);
  };
}
