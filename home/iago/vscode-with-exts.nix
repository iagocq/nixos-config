{ pkg, pkgs }:

let
  extensions = (with pkgs.vscode-extensions; [
    tamasfe.even-better-toml
    coenraads.bracket-pair-colorizer-2
    james-yu.latex-workshop
    xaver.clang-format
    matklad.rust-analyzer
    ms-python.python
    bbenoist.Nix
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./vscode-marketplace-exts.nix).extensions;
in
(pkgs.vscode-with-extensions.override {
  vscode = pkg;
  vscodeExtensions = extensions;
})

