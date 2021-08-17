{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" "snd-aloop" ];
  boot.kernelParams = [ "snd-aloop.index=10" "threadirqs" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "dev.hpet.max-user-freq" = 3072;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd = {
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

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    dpi = 96;
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
      Option "TripleBuffer" "on"
      Option "AllowIndirectGLXProtocol" "off"
    '';
  };


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1541a90c-fd26-496c-9e53-033abf751b7c";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/3b3f7ef4-55bf-4e73-a80d-0b2ec17c88a8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/d08362aa-1d99-4e73-8fcb-f5a931ddf8c9";
      fsType = "ext2";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/D0A3-51DC";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/fe31e3c0-e5d7-48b1-8446-716eb8a459c1"; }
    ];

}
