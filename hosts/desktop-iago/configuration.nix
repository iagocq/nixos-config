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
      luks.devices."root" = {
        device = "/dev/disk/by-uuid/0a07d8fc-b24f-43fc-b428-87d336eb8145";
        preLVM = true;
        keyFile = "/cryptlvm-key.bin";
        allowDiscards = true;
      };
      secrets = {
        "cryptlvm-key.bin" = "/boot/cryptlvm-key.bin";
      };
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };

  programs.gnupg.agent.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1541a90c-fd26-496c-9e53-033abf751b7c";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/3b3f7ef4-55bf-4e73-a80d-0b2ec17c88a8";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/d08362aa-1d99-4e73-8fcb-f5a931ddf8c9";
      fsType = "ext2";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/fe31e3c0-e5d7-48b1-8446-716eb8a459c1"; }
  ];

  system.stateVersion = "20.09";
}
