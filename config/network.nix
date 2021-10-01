rec {
  domain = "iago.casa";

  lan = rec {
    lan-subdomain = "intra";
    lan-domain = "${lan-subdomain}.${domain}";
    dns-server = "10.36.21.11";
    netmask = "255.255.255.0";
    subnet = "10.36.21.0/24";
    broadcast = "10.36.21.255";
    gateway = "10.36.21.1";

    default-route = {
      address = "0.0.0.0";
      prefixLength = 0;
      via = gateway;
    };

    server = {
      host = "raspberrypi";

      main-address = "10.36.21.10";

      addresses = [
        { address = "10.36.21.10"; prefixLength = 24; }
        { address = "10.36.21.11"; prefixLength = 24; }
      ];

      extra-hosts = ''
      '';
    };

    dhcp = rec {
      start = "10.36.21.50";
      end = "10.36.21.99";
      range = "${start},${end},${netmask},${broadcast}";
      dnsmasq-extra = ''
        host-record=${server.host}.${lan-domain},${server.host},${server.main-address}
      '';
    };

    bind = server.main-address;
  };
}
