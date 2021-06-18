{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules.nix

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

  # https://github.com/NixOS/nixpkgs/pull/85073
  # https://github.com/NixOS/nixpkgs/pull/123902
  # https://github.com/NixOS/nixpkgs/pull/124431
  # systemd.services.mount-pstore.enable = false;
}
