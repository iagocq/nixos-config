{ config, pkgs, lib, ... }: 

{
  services.picom = {
    enable = true;
    backend = "xrender";
    blur = true;
    shadow = true;
    # vSync = true;
    blurExclude = [ "class_g = 'slop'" ];
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
}
