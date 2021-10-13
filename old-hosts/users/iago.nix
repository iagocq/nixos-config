{ config, ... }:

{
  isNormalUser = true;
  extraGroups = [ "wheel" ];
  home = "/home/iago-nixos";
  openssh.authorizedKeys.keyFiles = config.common.secrets.keys.iago.pub-ssh;
}
