{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.full;
in
{
  options.spc.int.full = {
    enable = mkEnableOption "Use a specialized configuration for an internal server";
  };

  config = mkIf cfg.enable {
    spc.int = {
      dns.enable = true;
      dhcp.enable = true;
      acme.enable = true;
      bitwarden.enable = true;
      calibre.enable = true;
      nginx.enable = true;
    };
  };
}
