{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.device;
in
{
  options.device = {
    enable = mkOption {
      type = types.bool;
      default = !cfg.isHomeManager;
    };

    type = mkOption {
      type = types.enum [ "none" "desktop" "laptop" "embedded" "server" ];
      default = "none";
    };

    isDesktop = mkOption {
      type = types.bool;
      default = cfg.type == "desktop";
    };

    isLaptop = mkOption {
      type = types.bool;
      default = cfg.type == "laptop";
    };

    isEmbedded = mkOption {
      type = types.bool;
      default = cfg.type == "embedded";
    };

    isServer = mkOption {
      type = types.bool;
      default = cfg.type == "server";
    };

    isPc = mkOption {
      type = types.bool;
      default = with cfg; isDesktop || isLaptop;
    };

    isGraphical = mkOption {
      type = types.bool;
      default = cfg.isPc;
    };

    hasAudio = mkOption {
      type = types.bool;
      default = cfg.isPc;
    };

    isUefi = mkOption {
      type = types.bool;
      default = true;
    };

    isHomeManager = mkOption {
      type = types.bool;
      default = false;
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = mkDefault "America/Sao_Paulo";
    i18n.defaultLocale = mkDefault cfg.locale;

    console = mkDefault {
      font = "Lat2-Terminus16";
      keyMap = "br-abnt2";
    };

    system.activationScripts.diff = ''
      [ -e /run/current-system ] &&
      ${config.nix.package}/bin/nix store --experimental-features nix-command \
      diff-closures /run/current-system "$systemConfig"
    '';

    nix = {
      package = pkgs.nixUnstable;
      binaryCaches = lib.mkForce [
        "https://cache.ngi0.nixos.org/"
      ];
      binaryCachePublicKeys = lib.mkForce [
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
      ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-derivations ca-references
      '';
    };

    environment.noXlibs = false;

    environment.systemPackages = with pkgs; [
      vim htop file killall dnsutils coreutils lsof agenix
    ];

    environment.shells = [ pkgs.zsh ];

    services.openssh = {
      enable = mkDefault true;
      useDns = mkDefault true;
      passwordAuthentication = mkDefault false;
      permitRootLogin = mkDefault "no";
    };

    security.pam.loginLimits = [{
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "8192";
    }];
  };
}
