{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    zfs.requestEncryptionCredentials = [ "rpool/crypt" "ssd/crypt" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];

      # mkpasswd -m sha-512 -S "helloWORLD" | sudo tee /secrets/zfs-key-desktop-iago
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

  fileSystems."/nix" = lib.mkForce {
    device = "ssd/crypt/local/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/swap"; }
  ];

  system.stateVersion = "20.09";
}
