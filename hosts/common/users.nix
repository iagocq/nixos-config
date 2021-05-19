{ pkgs, ... }:

{
  users = {
    defaultUserShell = pkgs.zsh;

    users.iago = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      home = "/home/iago-nixos";
      openssh.authorizedKeys.keyFiles = [
        ../../keys/iago-pc.pub
        ../../keys/iago-rpi.pub
      ];
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
