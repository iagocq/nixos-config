{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking = {
    useDHCP = false;

    bridges = {
      lan.interfaces = [ "enp3s0f0" "enp3s0f1" ];
    };

    interfaces = {
      wlp1s0.useDHCP = false;
      enp3s0f0.useDHCP = false;
      enp3s0f1.useDHCP = false;
      enp2s0 = {
        macAddress = "00:1A:3F:60:B8:77";
        useDHCP = false;
      };

      lan = {
        ipv4.addresses = [{
          address = "10.36.21.1";
          prefixLength = 24;
        }];
      };
    };

    nat = {
      enable = true;
      internalInterfaces = [ "lan" ];
      externalInterface = "ppp0";
    };
  };

  services.pppd = {
    enable = true;
    peers.upstream = {
      autostart = true;
      enable = true;
      config = ''
        debug
        plugin rp-pppoe.so enp2s0
        hide-password
        file "${config.age.secrets.pppd-credentials.path}"

        persist
        maxfail 0
        holdoff 5

        noaccomp
        default-asyncmap
        mtu 1492

        lcp-echo-interval 10
        lcp-echo-failure 3

        noipdefault
        defaultroute

        noipv6
      '';
    };
  };

  services.hostapd = {
    enable = true;
    interface = "wlp1s0";
    ssid = "!";
    noScan = true;
    extraConfig = ''
      bridge=lan
      ieee80211n=1
      obss_interval=0
      ht_capab=[SHORT-GI-40][HT40+][HT40-]
      wpa=2
      wpa_key_mgmt=WPA-PSK
      wpa_pairwise=CCMP
      wpa_psk_file=${config.age.secrets.wpa-psk.path}
    '';
  };
}
