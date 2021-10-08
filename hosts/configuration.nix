{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules
    ./ssh.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  networking.useDHCP = false;

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  system.activationScripts.diff = ''
    [ -e /run/current-system ] &&
    ${pkgs.nixUnstable}/bin/nix store --experimental-features nix-command \
    diff-closures /run/current-system "$systemConfig"
  '';

  nix.package = pkgs.nixUnstable;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.systemPackages = with pkgs; [
    vim htop file killall nethogs dnsutils coreutils lsof
    agenix
  ];

  environment.shells = [ pkgs.zsh ];
}
