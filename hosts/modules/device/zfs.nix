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

    base = mkOption {
      type = types.str;
      default = "rpool";
    };

    root = mkOption {
      type = types.str;
      default = "${cfg.base}/local/root";
    };

    mounts = mkOption {
      type = types.attrsOf types.anything;
      default = {
        "/" = { device = "${cfg.root}"; fsType = "zfs"; };
        "/nix" = { device = "${cfg.base}/local/nix"; fsType = "zfs"; };
        "/home" = { device = "${cfg.base}/safe/home"; fsType = "zfs"; };
        "/persist" = { device = "${cfg.base}/safe/persist"; fsType = "zfs"; };
      };
    };

    mount = mkOption {
      type = types.bool;
      default = true;
    };

    eyd = {
      enable = mkOption {
        type = types.bool;
        default = cfg.mount;
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
    networking.hostId = mkDefault cfg.hostId;
    boot = {
      initrd = {
        postDeviceCommands = mkIf cfg.eyd.enable (mkAfter cfg.eyd.rollbackCommand);
        supportedFilesystems = [ "zfs" ];
      };
      supportedFilesystems = [ "zfs" ];
    };

    services.openssh.hostKeys = mkIf cfg.eyd.enable [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
