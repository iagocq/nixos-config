{ config, host ? "unknown", lib, pkgs, ... }:

{
  users.users.iago = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/iago-nixos";
    initialHashedPassword = "";

    openssh.authorizedKeys.keys =
      let trusted = (import ../default.nix { inherit lib pkgs; }).iago.keys.trusted; in
      trusted.${host} or [];
  };
}
