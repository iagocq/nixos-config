{ lib, ... }:

{
  services.openssh = {
    enable = true;
    useDns = true;
    passwordAuthentication = lib.mkDefault false;
    permitRootLogin = lib.mkDefault "no";
  };
}
