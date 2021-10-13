{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.kernelParams = [ "boot.shell_on_fail=1" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.availableKernelModules = [ "virtio_pci" "usbhid" ];
  boot.loader = {
    grub = {
      enable = lib.mkDefault true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
    efi.efiSysMountPoint = "/boot/efi";
  };

  fileSystems = lib.mkDefault {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/safe/home";
      fsType = "zfs";
    };
    "/persist" = {
      device = "rpool/safe/persist";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };
  };
}
