{ config, lib, pkgs, ... }:

{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "comp0" ];
    externalInterface = "enp0s3";
  };
  networking.wireguard.interfaces = {
    comp0 = let intf = "enp0s3"; in {
      ips = [ "10.36.21.1/24" ];
      listenPort = 443;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.36.21.0/24 -o ${intf} -j MASQUERADE 
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.36.21.0/24 -o ${intf} -j MASQUERADE 
      '';

      privateKeyFile = "/persist/wg/comp0/private";

      peers = [
        {
          publicKey = "nobFShJKZWTWxe2TSDv92vOSis990zDRrDaAWBzUTRQ=";
          allowedIPs = [ "10.36.21.2/32" ];
        }
      ];
    };
  };
}
