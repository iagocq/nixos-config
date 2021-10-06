{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.availableKernelModules = [ "virtio_pci" "usbhid" ];
  boot.loader = {
    grub = {
      enable = true;
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
    "/boot" = {
      device = "/dev/disk/by-label/boot";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };
  };
}
