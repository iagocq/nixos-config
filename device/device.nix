{ config, lib, pkgs, isHomeManager ? false, home-manager ? false, ... }:

with lib;
let
  cfg = config.device;
in
{
  options.device = {
    enable = mkOption {
      type = types.bool;
      default = true;
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
      default = isHomeManager;
    };

    homeManagerEnabled = mkOption {
      type = types.bool;
      default = home-manager;
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
    };
  };

  config = if !isHomeManager then mkIf cfg.enable {
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
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    programs.zsh.enable = true;

    environment.etc.zinputrc.text = mkForce "";
    environment.noXlibs = false;
    environment.systemPackages = with pkgs; [
      vim htop file killall dnsutils coreutils lsof agenix
    ];

    services.openssh = {
      enable = mkDefault true;
      useDns = mkDefault true;
      passwordAuthentication = mkDefault false;
      kbdInteractiveAuthentication = mkDefault false;
      permitRootLogin = mkDefault "no";
    };

    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';
  } else {};
}
