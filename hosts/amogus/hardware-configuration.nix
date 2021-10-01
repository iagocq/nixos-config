{ config, lib, pkgs, ... }:

{
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/" = { device = "/dev/disk/by-uuid/7abea936-8ed6-442f-a0f0-20a26b734c82"; fsType = "ext4"; };
  fileSystems."/boot/efi" = { device = "/dev/disk/by-label/UEFI"; fsType = "vfat"; };
}
