{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.mpv;
in
{
  options.custom.mpv = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    programs.mpv = mkIf cfg.enable {
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
  };
}
