{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.device.zfs;
in
{
  options.device.zfs = {
    enable = mkOption {
      type = types.bool;
      default = !config.device.isHomeManager;
    };

    pool = mkOption {
      type = types.str;
      default = "rpool";
    };

    root = mkOption {
      type = types.str;
      default = "${cfg.pool}/local/root";
    };

    mounts = mkOption {
      type = types.attrsOf types.anything;
      default = {
        "/" = { device = "${cfg.root}"; fsType = "zfs"; };
        "/nix" = { device = "${cfg.pool}/local/nix"; fsType = "zfs"; };
        "/home" = { device = "${cfg.pool}/safe/home"; fsType = "zfs"; };
        "/persist" = { device = "${cfg.pool}/safe/persist"; fsType = "zfs"; };
      };
    };

    mount = mkOption {
      type = types.bool;
      default = true;
    };

    eyd = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      rollbackCommand = mkOption {
        type = types.str;
        default = ''
          zfs rollback -r ${cfg.root}@blank
        '';
      };
    };

    hostId = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    fileSystems = mkIf cfg.mount cfg.mounts;
    boot = {
      initrd = {
        postDeviceCommands = mkIf cfg.eyd.enable (mkAfter cfg.eyd.rollbackCommand);
        supportedFilesystems = [ "zfs" ];
      };
      supportedFilesystems = [ "zfs" ];
    };
    networking.hostId = mkDefault cfg.hostId;
  };
}
