{ config, lib, pkgs, modulesPath,... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  nix.trustedUsers = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;

  spc.int.full.enable = true;
  spc.int.dhcp.enable = lib.mkForce false;

  networking = let network = config.spc.int.cfg.network; in {
    wireless.networks."!".pskRaw = "d967ef0bb297ba166bc834c9a2198ccb40876603cef13211b96793badb2c6f58";

    nameservers = [ network.dnsServer "1.1.1.1" ];
    domain = network.lanDomain;
    resolvconf.useLocalResolver = false;

    localCommands = ''
      ${pkgs.parprouted}/bin/parprouted eth0 wlan0
      ${pkgs.pptpd}/bin/bcrelay -d -n -i wlan0 -o eth0
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      firmwareLinuxNonfree = prev.firmwareLinuxNonfree.overrideAttrs (old: {
        version = "2020-12-18";
        src = pkgs.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "";
          sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
        };
        outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
      });
    })
  ];

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
