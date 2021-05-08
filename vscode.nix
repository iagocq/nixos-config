{config, pkgs, ...}:

let extensions = (with pkgs.vscode-extensions; [
  tamasfe.even-better-toml
  coenraads.bracket-pair-colorizer-2
  james-yu.latex-workshop
  xaver.clang-format
  matklad.rust-analyzer
  ms-python.python
]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "language-x86-64-assembly";
    publisher = "13xforever";
    version = "2.3.0";
    sha256 = "0lfbkvpwmvrsfzpvf0p0g2nnq1qg5p173vd5m4idq90r2vzypwg1";
  }
  {
    name = "better-comments";
    publisher = "aaron-bond";
    version = "2.1.0";
    sha256 = "0kmmk6bpsdrvbb7dqf0d3annpg41n9g6ljzc1dh0akjzpbchdcwp";
  }
  {
    name = "doxdocgen";
    publisher = "cschlosser";
    version = "1.1.0";
    sha256 = "05j79kp51nh0r1w95mjqgy62z2vsnzljzf9p8qv165b2553jdwh9";
  }
  {
    name = "vscode-clangd";
    publisher = "llvm-vs-code-extensions";
    version = "0.1.9";
    sha256 = "0kfxpcgxaswq2d1ybf9c5wzlqarcvy0fd0dg06fi4gfmnfrd6zga";
  }
  {
    name = "markdown-preview-enhanced";
    publisher = "shd101wyy";
    version = "0.5.16";
    sha256 = "0w5w2np8fkxpknq76yv8id305rxd8a1p84p9k0jwwwlrsyrz31q8";
  }
  {
    name = "rewrap";
    publisher = "stkb";
    version = "1.13.0";
    sha256 = "18h42vfxngix8x22nqslvnzwfvfq5kl35xs6fldi211dzwhw905j";
  }
  {
    name = "linkerscript";
    publisher = "ZixuanWang";
    version = "1.0.1";
    sha256 = "13fvv7g1ignky8yf48xykyhj1mxsrqdy4jn78n9l0d47hfmsc3q6";
  }
  {
    name = "vscode-opencl";
    publisher = "galarius";
    version = "0.6.6";
    sha256 = "0a3r2rwxvha8b26ldcsll9bdfp7vgw5sl3mxaq298mxywim8sl5p";
  }
];
vscodium-with-extensions = pkgs.vscode-with-extensions.override {
  vscode = pkgs.vscodium;
  vscodeExtensions = extensions;
}; in
{
  home.packages = [ vscodium-with-extensions ];
}
