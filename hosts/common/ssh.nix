{ ... }:

{
  services.openssh = {
    enable = true;
    useDns = true;
    permitRootLogin = "no";
  };
}
