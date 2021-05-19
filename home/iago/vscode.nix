{config, pkgs, ...}:

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
  vscodium-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = extensions;
  };
in
{
  home.packages = [ vscodium-with-extensions ];
}
