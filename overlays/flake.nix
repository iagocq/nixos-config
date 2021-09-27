{
  description = "Iago's NixOS overlays";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    tribler-nixpkgs.url = "github:viric/nixpkgs/tribler-master2";

    iago-nix.url = "github:iagocq/nix";

    zsh-f-sy-h = { url = "github:zdharma/fast-syntax-highlighting"; flake = false; };
    nnn-src = { url = "github:jarun/nnn"; flake = false; };
  };
  
  outputs = ({ ... }@inputs:
    let
      mkOverlays = ({ nixpkgs, system, overlays ? [] }:
        let
          cfg-final = nixpkgs // { inherit system; };
          nixpkgs-master = import inputs.nixpkgs-master cfg-final;
          tribler-nixpkgs = import inputs.tribler-nixpkgs cfg-final;
        in
        [
          (final: prev: {
            nixUnstable = prev.nixUnstable.override {
              patches = [ ./nix-unset-is-macho.patch ];
            };
            zsh-f-sy-h = inputs.zsh-f-sy-h;
            nnn-src = inputs.nnn-src;
            tribler = tribler-nixpkgs.pkgs.tribler;
          })
          inputs.iago-nix.overlay
        ] ++ overlays
      );
    in
    {
      inherit mkOverlays;
    }
  );
}
