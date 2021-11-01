{ config, lib, pkgs, ... }:

{
  imports = [
    ../amogus/configuration.nix
  ];

  device.uefi.mount = false;
  device.zfs.enable = false;
}
