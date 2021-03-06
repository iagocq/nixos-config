{ config, lib, pkgs, isHomeManager ? false, ... }:

with lib;
let
  cfg = config.device.zfs;
in
{
  options.device.zfs = {
    enable = mkOption {
      type = types.bool;
      default = true;
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
        "/nix" = { device = "${cfg.base}/local/nix"; fsType = "zfs"; neededForBoot = true; };
        "/home" = { device = "${cfg.base}/safe/home"; fsType = "zfs"; neededForBoot = true; };
        "/persist" = { device = "${cfg.base}/safe/persist"; fsType = "zfs"; neededForBoot = true; };
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

      persist = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
      };
    };

    hostId = mkOption {
      type = types.str;
    };
  };

  config = if !isHomeManager then mkIf cfg.enable {
    fileSystems = mkIf cfg.mount cfg.mounts;
    networking.hostId = cfg.hostId;

    boot = {
      kernelParams = [ "nohibernate" ];
      supportedFilesystems = [ "zfs" ];

      initrd = {
        postDeviceCommands = mkIf cfg.eyd.enable (mkAfter cfg.eyd.rollbackCommand);
        supportedFilesystems = [ "zfs" ];
      };
    };

    environment.persistence."/persist" = mkIf cfg.eyd.enable (recursiveUpdate cfg.eyd.persist {
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    });

    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';
  
    services.zfs = {
      trim.enable = true;
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  } else {};
}
