{ config, pkgs, ... }:

let
  s = config.common.secrets;
in
{
  users = {
    defaultUserShell = pkgs.zsh;

    users.iago = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      home = "/home/iago-nixos";
      openssh.authorizedKeys.keyFiles = s.keys.all-pub-ssh;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
