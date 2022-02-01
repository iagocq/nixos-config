{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.device.network;
  eyd = config.device.zfs.eyd;
in
{
  options.device.network = {
    enable = mkOption {
      type = types.bool;
      default = !config.device.isHomeManager;
    };

    firewall = mkOption {
      type = types.bool;
      default = true;
    };

    wireless = mkOption {
      type = types.bool;
      default = config.device.isLaptop;
    };

    backend = mkOption {
      type = types.enum [ "networkmanager" "dhcpcd" ];
      default = if config.device.isLaptop then "networkmanager" else "dhcpcd";
    };

    interfaces = {
      dhcp = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      static = mkOption {
        type = types.attrsOf types.anything;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "dhcpcd") {
      networking = {
        firewall.enable = mkDefault cfg.firewall;
        wireless.enable = mkOrder 2000 cfg.wireless;

        interfaces = mkMerge [
          cfg.interfaces.static
          (listToAttrs (map (x: { name = x; value.useDHCP = true; }) cfg.interfaces.dhcp))
        ];
      };
    })
    (mkIf (cfg.backend == "networkmanager") {
      networking.networkmanager.enable = true;
      device.zfs.eyd.persist = {
        files = [
          "/etc/NetworkManager/system-connections"
        ];
      };
    })
  ]);
}