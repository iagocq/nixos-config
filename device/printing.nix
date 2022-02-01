{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.device.printing;
in
{
  options.device.printing = {
    enable = mkOption {
      type = types.bool;
      default = with config.device; isPc && !isHomeManager;
    };
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
