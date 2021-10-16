{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];

      zfs.requestEncryptionCredentials = [ "rpool/crypt" ];

      luks.devices."secrets-desktop-iago" = {
        device = "/dev/disk/by-partlabel/secrets-desktop-iago";
        keyFile = "/dev/disk/by-partlabel/key-secrets-desktop-iago";
        fallbackToPassword = true;
        postOpenCommands = ''
          specialMount /dev/mapper/secrets-desktop-iago /secrets "" ext4
        '';
      };

      postMountCommands = ''
        umount /secrets
        cryptsetup close secrets-desktop-iago
      '';
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };

  programs.gnupg.agent.enable = true;

  swapDevices = [
    #{ device = "/dev/disk/by-uuid/fe31e3c0-e5d7-48b1-8446-716eb8a459c1"; }
  ];

  system.stateVersion = "20.09";
}
