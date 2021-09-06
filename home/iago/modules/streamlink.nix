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
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.streamlink ];

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
