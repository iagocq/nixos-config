{ config, libs, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      profile = "gpu-hq";
      hwdec = "auto-safe";
      af = "acompressor";
    };
    bindings = {
      n = "cycle_values af loudnorm=I=-30 loudnorm=I=-15 acompressor anull";
    };
  };
}
