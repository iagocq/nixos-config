{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_5_15;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
    kernelPatches = [
      { name = "csr"; patch = ./v2-Bluetooth-btusb-Add-a-new-quirk-to-skip-HCI_FLT_CLEAR_ALL-on-fake-CSR-controllers.diff; }
    ];
  }; 

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  swapDevices = [
    { device = "/dev/disk/by-partlabel/swap"; }
  ];

  system.stateVersion = "22.05";
}
