{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.vscode;
in
{
  options.custom.vscode = {
    enable = mkEnableOption "";

    package = mkOption {
      type = types.package;
      default = pkgs.vscodium;
    };

    extra-exts = mkOption {
      type = types.listOf types.anything;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.vscode-with-extensions.override {
        vscode = cfg.package;
        vscodeExtensions = (import ./vscode-marketplace-exts.nix).extensions ++ cfg.extra-exts;
      })
    ];
  };
}
