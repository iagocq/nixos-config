{ config, lib, isHomeManager ? false, ... }:

with lib;
let
  cfg = config.device.boot;
in
{
  options.device.boot = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    loader = mkOption {
      type = types.enum [ "none" "grub" "systemd-boot" "extlinux" "raspberrypi" ];
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
      default = "/dev/disk/by-partlabel/boot";
    };

    mount = mkOption {
      type = types.bool;
      default = cfg.loader != "extlinux";
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

  config = if !isHomeManager then mkIf cfg.enable {
    boot = {
      loader = mkMerge [
        { timeout = mkDefault 0; }

        (mkIf cfg.efi {
          efi = {
            canTouchEfiVariables = mkDefault (!cfg.removable);
            efiSysMountPoint = mkDefault cfg.efiMountPoint;
          };
        })

        (mkIf (cfg.loader == "grub") {
          grub = {
            enable = mkDefault true;
            version = 2;
            device = "nodev";
            efiSupport = true;
            efiInstallAsRemovable = mkDefault cfg.removable;
            enableCryptodisk = mkDefault cfg.cryptodisk;
          };
        })

        (mkIf (cfg.loader == "raspberrypi") {
          grub.enable = false;
          systemd-boot.enable = false;
          raspberryPi = {
            enable = true;
            version = 3;
          };
        })

        (mkIf (cfg.loader == "extlinux") {
          generic-extlinux-compatible.enable = mkDefault true;
        })

        (mkIf (cfg.loader == "systemd-boot") {
          systemd-boot.enable = true;
        })
      ];
    };

    fileSystems = mkIf cfg.mount {
      ${cfg.efiMountPoint} = mkIf cfg.efi (mkDefault { device = cfg.efiDevice; });
      ${cfg.bootMountPoint} = mkDefault { device = cfg.bootDevice; };
    };
  } else {};

}
