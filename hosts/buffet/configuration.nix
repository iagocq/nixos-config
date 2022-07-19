{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
    ./router.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;

  age.secrets = (import ./age.nix).age;
  age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" "/persist/etc/ssh/ssh_host_rsa_key" ];

  spc.int.full.enable = true;
  srv.local.dnsmasq.extraConfig = ''
    interface=lan
  '';

  srv.adguard.address = lib.mkForce "10.36.21.1";

  networking = let network = config.spc.int.network; in {
    nameservers = [ network.dnsServer "1.1.1.1" ];
    domain = network.lanDomain;
    resolvconf.useLocalResolver = false;
  };

  environment.persistence."/persist".directories = [
    { directory = "/var/lib/private/AdGuardHome"; user = "adguardhome"; group = "adguardhome"; }
    { directory = "/var/lib/acme"; user = "acme"; group = "acme"; }
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    #kernelPackages = pkgs.linuxPackages_5_15;
    #extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  }; 

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  swapDevices = [
    { device = "/dev/disk/by-partlabel/swap"; }
  ];

  system.stateVersion = "22.05";
}
