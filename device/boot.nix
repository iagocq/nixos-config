{ config, lib, ... }:

with lib;
let
  cfg = config.device.uefi;
in
{
  options.device.uefi = {
    enable = mkOption {
      type = types.bool;
      default = !config.device.isHomeManager;
    };

    bootloader = mkOption {
      type = types.enum [ "none" "grub" "systemd-boot" "extlinux" ];
      default = "systemd-boot";
    };

    efiMountPoint = mkOption {
      type = types.str;
      default = "/boot/efi";
    };

    efiDevice = mkOption {
      type = types.str;
      default = "/dev/disk/by-partlabel/UEFI";
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

    efi = mkOption {
      type = types.bool;
      default = config.device.isUefi;
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = mkMerge [
        {
          timeout = 0;
        }

        (mkIf cfg.efi {
          efi = {
            canTouchEfiVariables = mkDefault (!cfg.removable);
            efiSysMountPoint = mkDefault cfg.efiMountPoint;
          };
        })

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
        })

        (mkIf (cfg.bootloader == "systemd-boot") {
          systemd-boot = {
            enable = true;
          };
        })
      ];
    };

    fileSystems = mkIf cfg.mount {
      ${cfg.efiMountPoint} = mkIf cfg.efi (mkDefault { device = cfg.efiDevice; });
      ${cfg.bootMountPoint} = mkDefault { device = cfg.bootDevice; };
    };
  };

}
