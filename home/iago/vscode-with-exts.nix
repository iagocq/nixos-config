{ pkg, pkgs }:

pkgs.vscode-with-extensions.override {
  vscode = pkg;
  vscodeExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./vscode-marketplace-exts.nix).extensions;
}
