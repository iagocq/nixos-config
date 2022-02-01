{ config, host ? "unknown", lib, pkgs, ... }:

{
  users.users.iago = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/iago-nixos";
    hashedPassword = "$6$helloWORLD$tbPL0CQSL38dDGLwCtRFRZ.BuHRtyJFjJDXNaDufP91PIGNnI5CGPEjaZJ4PyYp6noX5TF40Ijj1zxG59HxiC/";

    openssh.authorizedKeys.keys =
      let trusted = (import ../default.nix { inherit lib pkgs; }).iago.keys.trusted; in
      trusted.${host} or [];
  };
}
