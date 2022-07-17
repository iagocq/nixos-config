{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  scp.int = {
    
  };

  networking = {
    bridges = {
      lan.interfaces = [ "enp3s0f0" "enp3s0f1" ];
    };

    interfaces = {
      enp2s0.useDHCP = false;
      enp3s0f0.useDHCP = false;
      enp3s0f1.useDHCP = false;

      lan = {
        ipv4.addresses = [{
          address = "10.36.21.3";
          prefixLength = 24;
        }];
      };
    };

    nat = {
      internalInterfaces = [ "lan" ];
      externalInterface = "enp2s0";
    };
  };

  services.pppd = {
    enable = true;
    peers.upstream = {
      autostart = true;
      enable = true;
      config = ''
        plugin rp-pppoe.so enp2s0
        file "${config.age.secrets.pppd-credentials.path}";

        persist
        maxfail 0
        holdoff 5

        noipdefault
        defaultroute
      '';
    };
  };
}
