{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.streamlink;
in
{
  options.custom.streamlink = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.streamlink;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "streamlink/config".text = ''
        player=mpv
        player-no-close
        default-stream=best
      '';
      
      "streamlink/config.twitch".text = ''
        twitch-low-latency
      '';
    };
  };
}
