{ config, lib, pkgs, ... }: 

with lib;

let
  cfg = config.custom.picom;
in
{
  options.custom.picom = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    services.picom = mkIf cfg.enable {
      enable = true;
      backend = "xrender";
      # blur = true;
      shadow = true;
      # vSync = true;
      # blurExclude = [ "class_g = 'slop'" ];
      shadowExclude = [ "class_g = 'Firefox' && argb" ];
      opacityRule = [
        "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_FULLSCREEN'" 
        "100:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_FULLSCREEN'" 
        "100:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_FULLSCREEN'"
      ];
      extraOptions = ''
        unredir-if-possible = true;
      '';
    };
  };
}
