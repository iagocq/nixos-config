{ config, lib, pkgs, mainUser, ... }:

with lib;
let
  cfg = config.device.graphics;
in
{
  options.device.graphics = {
    enable = mkOption {
      type = types.bool;
      default = with config.device; isGraphical && !isHomeManager;
    };

    backend = mkOption {
      type = types.enum [ "x" "wayland" ];
      default = "x";
    };

    dm = mkOption {
      type = types.enum [ "none" "sddm" ];
      default = "sddm";
    };

    autoLogin = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      relogin = mkOption {
        type = types.bool;
        default = true;
      };
    };

    de = mkOption {
      type = types.enum [ "none" "xfce" "kde" ];
      default = "xfce";
    };

    wm = mkOption {
      type = types.enum [ "none" "i3" ];
      default = "none";
    };

    xconfig = mkOption {
      type = types.attrsOf types.anything;
      default = {
        layout = "br";
      };
    };
  };
  
  config = mkIf cfg.enable {
    hardware.opengl.driSupport32Bit = mkDefault true;

    services.xserver = mkIf (cfg.backend == "x") (mkMerge [
      cfg.xconfig
      {
        enable = true;

        displayManager = {
          sddm = mkIf (cfg.dm == "sddm") {
            enable = true;
            autoLogin.relogin = mkDefault cfg.autoLogin.relogin;
          };
          autoLogin = mkIf cfg.autoLogin.enable {
            enable = true;
            user = cfg.autoLogin.user;
          };
          defaultSession = "${cfg.de}" + optionalString (cfg.wm != "none") "+${cfg.wm}";
        };

        desktopManager = {
          xfce = mkIf (cfg.de == "xfce") {
            enable = true;
            noDesktop = mkDefault (cfg.wm != "none");
            enableXfwm = mkDefault (cfg.wm == "none");
          };
        };

        windowManager = {
          i3 = mkIf (cfg.wm == "i3") {
            enable = true;
            package = pkgs.i3-gaps;
          };
        };
      }
    ]);
  };
}
