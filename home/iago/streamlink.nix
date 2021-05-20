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

  config = {
    xdg.configFile = mkIf cfg.enable {
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
