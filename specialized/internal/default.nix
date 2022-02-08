{ ... }:

{
  imports = [
    ./acme.nix
    ./bitwarden.nix
    ./calibre.nix
    ./dhcp.nix
    ./dns.nix
    ./full.nix
  # ./jellyfin.nix
    ./network.nix
    ./nginx.nix
  ];
}
