{ config, lib, ... }:

with lib;
let
  cfg = config.device.uefi;
in
{
  options.device.uefi = {
    enable = mkOption {
      type = types.bool;
      default = with config.device; isUefi && !isHomeManager;
    };

    bootloader = mkOption {
      type = types.enum [ "none" "grub" "systemd-boot" "extlinux" ];
      default = "grub";
    };

    efiMountPoint = mkOption {
      type = types.str;
      default = "/boot/efi";
    };

    efiDevice = mkOption {
      type = types.str;
      default = "/dev/disk/by-label/UEFI";
    };

    bootMountPoint = mkOption {
      type = types.str;
      default = "/boot";
    };

    bootDevice = mkOption {
      type = types.str;
      default = "/dev/disk/by-label/boot";
    };

    mount = mkOption {
      type = types.bool;
      default = cfg.bootloader != "extlinux";
    };

    cryptodisk = mkOption {
      type = types.bool;
      default = false;
    };

    removable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    boot.loader = mkMerge [
      {
        efi = {
          canTouchEfiVariables = mkDefault (!cfg.removable);
          efiSysMountPoint = mkDefault cfg.efiMountPoint;
        };
      }

      (mkIf (cfg.bootloader == "grub") {
        grub = {
          enable = mkDefault true;
          version = 2;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = mkDefault cfg.removable;
          enableCryptodisk = mkDefault cfg.cryptodisk;
        };
      })

      (mkIf (cfg.bootloader == "extlinux") {
        generic-extlinux-compatible.enable = mkDefault true;
        grub.enable = mkDefault false;
      })
    ];

    fileSystems = mkIf cfg.mount {
      ${cfg.efiMountPoint} = mkDefault { device = cfg.efiDevice; };
      ${cfg.bootMountPoint} = mkDefault { device = cfg.bootDevice; };
    };
  };
}
