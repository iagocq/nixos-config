{ lib, ... }:

with lib;
{
  imports = [
    ./acme.nix
    ./adguard.nix
    ./audio.nix
    ./bind.nix
    ./bitwarden_rs.nix
    ./calibre.nix
    ./dnsmasq.nix
    ./lightspeed.nix
    ./nginx.nix
    ./secrets.nix
    ./sslh.nix
  ];
}
