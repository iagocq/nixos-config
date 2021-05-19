{config, pkgs, lib, ... }:

{
  xdg.configFile."streamlink/config".text = ''
    player=mpv
    player-no-close
    default-stream=best
  '';
  xdg.configFile."streamlink/config.twitch".text = ''
    twitch-low-latency
  '';
}
