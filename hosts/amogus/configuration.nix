{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./device.nix
  ];

  boot = {
    kernelParams = [ "boot.shell_on_fail" ];
    initrd.availableKernelModules = [ "virtio_pci" "usbhid" ];
  };

  services.gitlab-runner = {
    enable = true;
  };
}
