{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

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
    "/" = { device = "/dev/disk/by-uuid/7abea936-8ed6-442f-a0f0-20a26b734c82"; fsType = "ext4"; };
    "/boot/efi" = { device = "/dev/disk/by-uuid/D058-E526"; fsType = "vfat"; };
  };
}
