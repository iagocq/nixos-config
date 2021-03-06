{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.alacritty;
in
{
  options.custom.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    cmd = mkOption {
      type = types.str;
      default = "${pkgs.alacritty}/bin/alacritty";
    };
  };

  config = mkIf cfg.enable {
    custom.terminal.cmd = cfg.cmd;
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.7;
        colors = {
          # Default colors
          primary = {
            background = "#2c2c2c";
            foreground = "#d6d6d6";

            dim_foreground =    "#dbdbdb";
            bright_foreground = "#d9d9d9";
            dim_background =    "#202020";
            bright_background = "#3a3a3a";
          };

          # Cursor colors
          cursor = {
            text =   "#2c2c2c";
            cursor = "#d9d9d9";
          };

          # Normal colors
          normal = {
            black =   "#1c1c1c";
            red =     "#bc5653";
            green =   "#909d63";
            yellow =  "#ebc17a";
            blue =    "#7eaac7";
            magenta = "#aa6292";
            cyan =    "#86d3ce";
            white =   "#cacaca";
          };

          # Bright colors
          bright = {
            black =   "#636363";
            red =     "#bc5653";
            green =   "#909d63";
            yellow =  "#ebc17a";
            blue =    "#7eaac7";
            magenta = "#aa6292";
            cyan =    "#86d3ce";
            white =   "#f7f7f7";
          };

          # Dim colors
          dim = {
            black =   "#232323";
            red =     "#74423f";
            green =   "#5e6547";
            yellow =  "#8b7653";
            blue =    "#556b79";
            magenta = "#6e4962";
            cyan =    "#5c8482";
            white =   "#828282";
          };
        };
      };
    };
  };
}
