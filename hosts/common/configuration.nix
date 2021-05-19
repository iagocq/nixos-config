{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./ssh.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.systemPackages = with pkgs; [
    vim htop file killall nethogs dnsutils coreutils lsof
  ];
}
