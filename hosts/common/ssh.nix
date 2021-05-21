{ lib, ... }:

{
  services.openssh = {
    enable = true;
    useDns = true;
    permitRootLogin = lib.mkDefault "no";
  };
}
