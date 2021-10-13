{ config, lib, pkgs, modulesPath,... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  nix.trustedUsers = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;

  spc.int.full.enable = true;

  networking = let network = config.spc.int.cfg.network; in {
    nameservers = [ network.dnsServer ];
    domain = network.lanDomain;
    resolvconf.useLocalResolver = false;
  };

  zramSwap.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/swapfile"; size = 1024; }
  ];
}
